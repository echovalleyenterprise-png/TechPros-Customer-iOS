import Foundation

final class ChatService {
    static let shared = ChatService()
    private init() {}

    // MARK: - Chat Request

    private struct ChatRequest: Encodable {
        let messages: [APIMessage]
        let conversationId: String?
        let customerSafeMode: Bool   // always true for customer app
        let language: String
        let mode: String             // always "customer"
    }

    // MARK: - Stream chat (SSE)

    func streamChat(
        messages: [ChatMessage],
        conversationId: String?,
        language: String
    ) async throws -> AsyncThrowingStream<String, Error> {
        let apiMessages = buildAPIMessages(from: messages)
        let body = ChatRequest(
            messages: apiMessages,
            conversationId: conversationId,
            customerSafeMode: true,
            language: language,
            mode: "customer"
        )

        let (asyncBytes, response) = try await APIClient.shared.stream("/api/chat", body: body)

        if let http = response as? HTTPURLResponse, http.statusCode == 401 {
            throw APIError.unauthorized
        }

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await line in asyncBytes.lines {
                        // Vercel streams SSE: lines starting with "data: "
                        if line.hasPrefix("data: ") {
                            let chunk = String(line.dropFirst(6))
                            if chunk == "[DONE]" { break }
                            continuation.yield(chunk)
                        } else if !line.isEmpty {
                            // Plain text fallback
                            continuation.yield(line)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Build API messages

    private func buildAPIMessages(from messages: [ChatMessage]) -> [APIMessage] {
        messages.map { msg in
            var parts: [APIContent] = []
            if let imageData = msg.imageData {
                let mediaType = msg.imageMediaType ?? "image/jpeg"
                parts.append(APIContent(imageData: imageData, mediaType: mediaType))
            }
            if !msg.content.isEmpty {
                parts.append(APIContent(text: msg.content))
            }
            if parts.isEmpty { parts.append(APIContent(text: " ")) }
            return APIMessage(role: msg.role.rawValue, content: parts)
        }
    }
}
