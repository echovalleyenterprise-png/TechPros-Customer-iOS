import SwiftUI

// MARK: - Customer-styled text field

struct CustomerField<Tag: Hashable>: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    @FocusState.Binding var focused: Tag?
    let tag: Tag?

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .autocapitalization(keyboardType == .emailAddress ? .none : .words)
            .autocorrectionDisabled(keyboardType == .emailAddress)
            .focused($focused, equals: tag)
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(focused == tag ? Color(red: 0.1, green: 0.5, blue: 1.0).opacity(0.5) : Color.gray.opacity(0.15), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }
}

// MARK: - Secure field

struct CustomerSecureField<Tag: Hashable>: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var focused: Tag?
    let tag: Tag?
    @State private var isVisible = false

    var body: some View {
        HStack {
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .focused($focused, equals: tag)

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(focused == tag ? Color(red: 0.1, green: 0.5, blue: 1.0).opacity(0.5) : Color.gray.opacity(0.15), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }
}

// MARK: - Error banner

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.07))
        .cornerRadius(12)
    }
}

// MARK: - Splash / loading screen

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.94, green: 0.97, blue: 1.0), Color.white],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 90, height: 90)
                        .shadow(color: .blue.opacity(0.3), radius: 20, y: 8)
                    Image(systemName: "house.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.white)
                }
                Text("Tech Pros")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                ProgressView().tint(Color(red: 0.1, green: 0.5, blue: 1.0))
            }
        }
    }
}
