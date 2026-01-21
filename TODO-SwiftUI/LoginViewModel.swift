import Foundation
import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let auth: AuthStore
    let onSuccess: () -> Void

    init(auth: AuthStore, onSuccess: @escaping () -> Void) {
        self.auth = auth
        self.onSuccess = onSuccess
    }

    func validate() -> String? {
        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Username or email is required."
        }
        if username.contains("@") {
            // rudimentary email format check
            let parts = username.split(separator: "@")
            if parts.count != 2 || parts[1].split(separator: ".").count < 2 {
                return "Please enter a valid email address."
            }
        }
        if password.isEmpty { return "Password is required." }
        if password.count < 6 { return "Password must be at least 6 characters." }
        return nil
    }

    func submit() async {
        if let msg = validate() {
            errorMessage = msg
            return
        }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await auth.login(username: username, password: password)
            onSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
