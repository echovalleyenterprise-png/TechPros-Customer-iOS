import SwiftUI

struct ConversationHistoryView: View {
    @ObservedObject var vm: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoadingHistory {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.conversations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No past conversations")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Button {
                            Task { await vm.startNewConversation() }
                            dismiss()
                        } label: {
                            Label("New conversation", systemImage: "square.and.pencil")
                                .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
                        }

                        ForEach(vm.conversations) { conv in
                            Button {
                                Task { await vm.openConversation(conv.id) }
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(conv.title ?? "Conversation")
                                        .font(.subheadline).fontWeight(.medium)
                                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                                    Text(conv.updated_at, style: .relative)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !vm.conversations.isEmpty {
                        Button("Clear", role: .destructive) { showClearConfirm = true }
                    }
                }
            }
            .confirmationDialog("Clear all history?", isPresented: $showClearConfirm, titleVisibility: .visible) {
                Button("Clear All", role: .destructive) {
                    Task { await vm.clearHistory() }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
