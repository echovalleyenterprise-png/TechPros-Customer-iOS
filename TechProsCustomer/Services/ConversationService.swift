import Foundation

final class ConversationService {
    static let shared = ConversationService()
    private init() {}

    // MARK: - Create

    func createConversation(title: String?) async throws -> String {
        struct Body: Encodable { let title: String? }
        struct Response: Decodable { let conversation: ConvInfo? }
        struct ConvInfo: Decodable { let id: String }
        let resp: Response = try await APIClient.shared.post(
            "/api/conversations",
            body: Body(title: title)
        )
        guard let id = resp.conversation?.id else {
            throw APIError.serverError("Failed to create conversation")
        }
        return id
    }

    // MARK: - List

    func listConversations() async throws -> [ConversationListItem] {
        struct Response: Decodable { let conversations: [ConversationListItem] }
        let resp: Response = try await APIClient.shared.get("/api/conversations")
        return resp.conversations
    }

    // MARK: - Load messages

    func loadMessages(conversationId: String) async throws -> [ChatMessage] {
        struct Response: Decodable { let messages: [StoredMessage] }
        struct StoredMessage: Decodable {
            let id: String; let role: String; let content: String; let created_at: Date
        }
        let resp: Response = try await APIClient.shared.get("/api/conversations/\(conversationId)")
        return resp.messages.map {
            ChatMessage(id: $0.id, role: $0.role == "user" ? .user : .assistant, content: $0.content, timestamp: $0.created_at)
        }
    }

    // MARK: - Delete all

    func deleteAll() async throws {
        try await APIClient.shared.delete("/api/conversations")
    }
}
