import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class AuthStore: ObservableObject {
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var currentSession: Session?

    private var modelContext: ModelContext
    private let api: APIHandler

    init(modelContext: ModelContext, api: APIHandler) {
        self.modelContext = modelContext
        self.api = api
        loadSession()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task {
            await api.setModelContext(context)
            await MainActor.run {
                self.loadSession()
            }
        }
    }

    private func loadSession() {
        let descriptor = FetchDescriptor<Session>()
        if let session = try? modelContext.fetch(descriptor).first {
            currentSession = session
            isLoggedIn = true
        } else {
            currentSession = nil
            isLoggedIn = false
        }
    }

    struct LoginRequest: Encodable {
        let username: String
        let password: String
        let expiresInMins: Int
    }

    struct LoginResponse: Decodable {
        let id: Int
        let username: String
        let email: String?
        let accessToken: String?
        let token: String?
        let refreshToken: String?
        let expiresInMins: Int?
    }

    func login(username: String, password: String) async throws {
        let req = LoginRequest(username: "emilys", password: "emilyspass", expiresInMins: 30)
        let resp: LoginResponse = try await api.request("/auth/login", method: "POST", body: req, authorized: false)

        let access = resp.accessToken ?? resp.token ?? ""
        guard !access.isEmpty else { throw APIError.unauthorized }

        // Save session
        let session = Session(
            username: resp.username,
            email: resp.email,
            accessToken: access,
            refreshToken: resp.refreshToken,
            accessTokenExpiry: resp.expiresInMins.flatMap { Date().addingTimeInterval(TimeInterval($0 * 60)) },
            userId: resp.id
        )
        // Clear existing sessions
        let existing = try? modelContext.fetch(FetchDescriptor<Session>())
        existing?.forEach { modelContext.delete($0) }
        modelContext.insert(session)
        try? modelContext.save()

        currentSession = session
        isLoggedIn = true
    }

    func logout() {
        let existing = try? modelContext.fetch(FetchDescriptor<Session>())
        existing?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        currentSession = nil
        isLoggedIn = false
    }
}
