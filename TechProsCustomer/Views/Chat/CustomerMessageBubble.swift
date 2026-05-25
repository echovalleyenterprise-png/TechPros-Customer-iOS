import SwiftUI

struct CustomerMessageBubble: View {
    let message: ChatMessage
    var onThumbsUp: () -> Void
    var onThumbsDown: () -> Void

    @State private var feedbackGiven: Int? = nil
    @State private var showFeedback = false

    private var isUser: Bool { message.role == .user }
    private var isStreaming: Bool { message.role == .assistant && message.content.isEmpty }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 60) }

            if !isUser {
                // Bot avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 30, height: 30)
                    Image(systemName: "house.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                }
                .alignmentGuide(.bottom) { d in d[.bottom] }
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                // Image preview
                if let imageData = message.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 220, maxHeight: 180)
                        .cornerRadius(18)
                        .clipped()
                }

                // Bubble
                if isStreaming {
                    HStack(spacing: 4) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(Color(red: 0.1, green: 0.5, blue: 1.0).opacity(0.5))
                                .frame(width: 7, height: 7)
                                .offset(y: isStreaming ? -3 : 0)
                                .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15), value: isStreaming)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                } else if !message.content.isEmpty {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(isUser ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            isUser
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                : AnyShapeStyle(Color.white)
                        )
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(isUser ? 0 : 0.06), radius: 4, y: 2)
                }

                // Feedback for assistant
                if !isUser && !message.content.isEmpty {
                    HStack(spacing: 12) {
                        Button {
                            feedbackGiven = 1
                            onThumbsUp()
                        } label: {
                            Image(systemName: feedbackGiven == 1 ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .font(.caption)
                                .foregroundColor(feedbackGiven == 1 ? Color(red: 0.1, green: 0.5, blue: 1.0) : .secondary)
                        }
                        Button {
                            feedbackGiven = -1
                            onThumbsDown()
                        } label: {
                            Image(systemName: feedbackGiven == -1 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                .font(.caption)
                                .foregroundColor(feedbackGiven == -1 ? .red : .secondary)
                        }
                    }
                    .padding(.leading, 4)
                }
            }

            if !isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 5)
    }
}
