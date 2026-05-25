import Foundation

// MARK: - Chat Message

struct ChatMessage: Identifiable, Equatable {
    let id: String
    var role: MessageRole
    var content: String
    var imageData: Data?
    var imageMediaType: String?
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        role: MessageRole,
        content: String,
        imageData: Data? = nil,
        imageMediaType: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.imageData = imageData
        self.imageMediaType = imageMediaType
        self.timestamp = timestamp
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content
    }
}

enum MessageRole: String {
    case user, assistant
}

// MARK: - Conversation

struct ConversationListItem: Identifiable, Decodable {
    let id: String
    let title: String?
    let created_at: Date
    let updated_at: Date
}

// MARK: - API message format

struct APIMessage: Encodable {
    let role: String
    let content: [APIContent]
}

struct APIContent: Encodable {
    let type: String
    let text: String?
    let source: APIImageSource?

    init(text: String) {
        self.type = "text"
        self.text = text
        self.source = nil
    }

    init(imageData: Data, mediaType: String) {
        self.type = "image"
        self.text = nil
        self.source = APIImageSource(
            type: "base64",
            mediaType: mediaType,
            data: imageData.base64EncodedString()
        )
    }
}

struct APIImageSource: Encodable {
    let type: String
    let mediaType: String
    let data: String
    enum CodingKeys: String, CodingKey {
        case type, mediaType = "media_type", data
    }
}
