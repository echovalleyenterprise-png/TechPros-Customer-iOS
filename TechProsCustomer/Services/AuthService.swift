import Foundation
import Supabase

final class AuthService {
    static let shared = AuthService()
    private init() {}

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }

    // MARK: - Sign Up (customer role)

    struct SignUpResult {
        let requiresEmailConfirmation: Bool
    }

    func signUp(fullName: String, email: String, password: String) async throws -> SignUpResult {
        struct Response: Decodable {
            let success: Bool
            let requiresEmailConfirmation: Bool?
            let error: String?
        }
        let resp: Response = try await APIClient.shared.postPublic(
            "/api/auth/signup",
            body: ["fullName": fullName, "email": email, "password": password, "role": "customer", "phone": ""]
        )
        if let err = resp.error { throw APIError.serverError(err) }
        return SignUpResult(requiresEmailConfirmation: resp.requiresEmailConfirmation ?? true)
    }

    // MARK: - Forgot Password

    func forgotPassword(email: String) async throws {
        struct Resp: Decodable { let success: Bool?; let error: String? }
        let resp: Resp = try await APIClient.shared.postPublic(
            "/api/auth/forgot-password",
            body: ["email": email]
        )
        if let err = resp.error { throw APIError.serverError(err) }
    }

    // MARK: - Resend Verification

    func resendVerification(email: String) async throws {
        struct Resp: Decodable { let success: Bool?; let error: String? }
        let resp: Resp = try await APIClient.shared.postPublic(
            "/api/auth/resend-verification",
            body: ["email": email]
        )
        if let err = resp.error { throw APIError.serverError(err) }
    }

    // MARK: - Sign Out

    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
