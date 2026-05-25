import SwiftUI
import PhotosUI

struct CustomerChatView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = ChatViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.99).ignoresSafeArea()

                VStack(spacing: 0) {
                    messageList
                    inputBar
                }
            }
            .navigationTitle("Tech Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Task { await vm.loadConversations() }
                        vm.showHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await vm.startNewConversation() }
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
                    }
                }
            }
            .sheet(isPresented: $vm.showHistory) {
                ConversationHistoryView(vm: vm)
            }
        }
        .task { AppState.current = appState }
        .onChange(of: vm.selectedPhotoItem) { _, _ in Task { await vm.loadSelectedPhoto() } }
    }

    // MARK: - Message list

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if vm.messages.isEmpty {
                        emptyState
                    }
                    ForEach(vm.messages) { message in
                        CustomerMessageBubble(
                            message: message,
                            onThumbsUp:   { Task { await vm.submitFeedback(messageId: message.id, rating: 1) } },
                            onThumbsDown: { Task { await vm.submitFeedback(messageId: message.id, rating: -1) } }
                        )
                        .id(message.id)
                    }
                    if let err = vm.errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.bottom, 12)
            }
            .onChange(of: vm.messages.count) { _, _ in
                if let last = vm.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: vm.messages.last?.content) { _, _ in
                if let last = vm.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 70, height: 70)
                        .shadow(color: .blue.opacity(0.25), radius: 12, y: 4)
                    Image(systemName: "house.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)

                Text("Hi \(appState.displayName)! 👋")
                    .font(.title3).fontWeight(.bold)
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                Text("Ask me anything about your home devices.\nI'm here to help!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Quick action grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(vm.quickActions, id: \.title) { action in
                    Button {
                        Task { await vm.sendQuickAction(action.prompt) }
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(action.title.prefix(2)))
                                .font(.title2)
                            Text(String(action.title.dropFirst(2)).trimmingCharacters(in: .whitespaces))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Input bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.3)

            // Image preview
            if let imageData = vm.pendingImageData, let uiImage = UIImage(data: imageData) {
                HStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .cornerRadius(12)
                        .clipped()
                    Spacer()
                    Button { vm.pendingImageData = nil; vm.selectedPhotoItem = nil } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }

            HStack(spacing: 10) {
                // Photo picker
                PhotosPicker(selection: $vm.selectedPhotoItem, matching: .images) {
                    Image(systemName: "photo")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0).opacity(0.7))
                        .frame(width: 36, height: 36)
                }

                // Voice
                VoiceInputButton(text: $vm.inputText)

                // Text field
                TextField("Ask a question...", text: $vm.inputText, axis: .vertical)
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    .tint(Color(red: 0.1, green: 0.5, blue: 1.0))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
                    .lineLimit(1...5)

                // Send / stop
                Button {
                    if vm.isStreaming { vm.stopStreaming() }
                    else { hideKeyboard(); Task { await vm.sendMessage() } }
                } label: {
                    Image(systemName: vm.isStreaming ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(
                            (vm.inputText.isEmpty && vm.pendingImageData == nil && !vm.isStreaming)
                                ? AnyShapeStyle(Color.gray.opacity(0.3))
                                : AnyShapeStyle(LinearGradient(
                                    colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                        )
                }
                .disabled(vm.inputText.isEmpty && vm.pendingImageData == nil && !vm.isStreaming)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(Color(red: 0.96, green: 0.97, blue: 0.99))
    }
}

// MARK: - Keyboard helper

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
