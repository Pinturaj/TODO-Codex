import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var userId: String = ""

    private let auth: AuthStore

    init(auth: AuthStore) {
        self.auth = auth
        reload()
    }

    func reload() {
        username = auth.currentSession?.username ?? ""
        email = auth.currentSession?.email ?? ""
        if let id = auth.currentSession?.userId {
            userId = String(id)
        } else {
            userId = ""
        }
    }

    func logout() {
        auth.logout()
    }
}
