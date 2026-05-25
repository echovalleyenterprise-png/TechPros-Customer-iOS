import SwiftUI
import PhotosUI

@MainActor
final class ChatViewModel: ObservableObject {
    // MARK: - Messages
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isStreaming = false
    @Published var errorMessage: String?

    // MARK: - Image
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var pendingImageData: Data?
    @Published var pendingImageMediaType: String = "image/jpeg"

    // MARK: - Conversation
    @Published var conversationId: String?
    @Published var conversations: [ConversationListItem] = []
    @Published var showHistory = false
    @Published var isLoadingHistory = false

    // MARK: - Settings
    @Published var language: String = "en"

    // MARK: - Streaming
    private var streamingMessageId: String?

    // MARK: - Quick actions for customers
    let quickActions: [(title: String, prompt: String)] = [
        ("📺 TV Setup Help",        "I need help setting up my new TV. Can you walk me through the basic setup?"),
        ("📶 WiFi Problems",         "My device won't connect to WiFi. What should I try?"),
        ("🔔 Doorbell Not Working",  "My video doorbell isn't working properly. How do I troubleshoot it?"),
        ("🌡️ Thermostat Help",       "I'm having trouble with my smart thermostat. Can you help me fix it?"),
        ("📷 Camera Setup",          "Help me get my security camera set up and working."),
        ("🔊 Sound Issues",          "My soundbar or TV speakers aren't working right. What should I check?"),
        ("💡 Smart Lights",          "My smart lights won't respond to the app. How do I fix this?"),
        ("🔧 Device Reset",          "How do I reset my device back to factory settings?")
    ]

    // MARK: - Init

    init() {
        Task { await startNewConversation() }
    }

    // MARK: - New conversation

    func startNewConversation() async {
        messages = []
        conversationId = nil
        streamingMessageId = nil
        do {
            conversationId = try await ConversationService.shared.createConversation(title: nil)
        } catch {
            // Non-fatal — chat still works without persistence
            print("Conversation creation failed: \(error)")
        }
    }

    // MARK: - Send message

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let image = pendingImageData
        let mediaType = pendingImageMediaType
        guard !text.isEmpty || image != nil else { return }

        let userMsg = ChatMessage(
            role: .user,
            content: text,
            imageData: image,
            imageMediaType: image != nil ? mediaType : nil
        )
        messages.append(userMsg)
        inputText = ""
        pendingImageData = nil
        selectedPhotoItem = nil

        // Ensure conversation
        if conversationId == nil {
            do {
                conversationId = try await ConversationService.shared.createConversation(
                    title: text.isEmpty ? "Photo question" : String(text.prefix(50))
                )
            } catch { print("Conversation error: \(error)") }
        }

        // Stream AI response
        let assistantId = UUID().uuidString
        streamingMessageId = assistantId
        messages.append(ChatMessage(id: assistantId, role: .assistant, content: ""))
        isStreaming = true
        errorMessage = nil

        do {
            let stream = try await ChatService.shared.streamChat(
                messages: messages.dropLast(),
                conversationId: conversationId,
                language: language
            )
            for try await chunk in stream {
                guard streamingMessageId == assistantId else { break }
                if let idx = messages.firstIndex(where: { $0.id == assistantId }) {
                    messages[idx].content += chunk
                }
            }
        } catch APIError.unauthorized {
            errorMessage = "Your session expired. Please sign in again."
            messages.removeAll { $0.id == assistantId }
        } catch {
            errorMessage = "Something went wrong. Please try again."
            messages.removeAll { $0.id == assistantId }
        }

        streamingMessageId = nil
        isStreaming = false
    }

    // MARK: - Quick action

    func sendQuickAction(_ prompt: String) async {
        inputText = prompt
        await sendMessage()
    }

    // MARK: - Stop streaming

    func stopStreaming() {
        streamingMessageId = nil
        isStreaming = false
    }

    // MARK: - Photo

    func loadSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        pendingImageData = data
        pendingImageMediaType = "image/jpeg"
    }

    // MARK: - History

    func loadConversations() async {
        isLoadingHistory = true
        do {
            conversations = try await ConversationService.shared.listConversations()
        } catch {
            conversations = []
        }
        isLoadingHistory = false
    }

    func openConversation(_ id: String) async {
        do {
            let loaded = try await ConversationService.shared.loadMessages(conversationId: id)
            messages = loaded
            conversationId = id
            showHistory = false
        } catch {
            showHistory = false
        }
    }

    func clearHistory() async {
        try? await ConversationService.shared.deleteAll()
        conversations = []
        await startNewConversation()
    }

    // MARK: - Feedback

    func submitFeedback(messageId: String, rating: Int) async {
        struct Body: Encodable { let messageId: String?; let conversationId: String?; let rating: Int; let source: String }
        struct Resp: Decodable { let success: Bool? }
        let _: Resp? = try? await APIClient.shared.post("/api/feedback", body: Body(
            messageId: nil,
            conversationId: conversationId,
            rating: rating,
            source: "customer"
        ))
    }
}
