import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class AuthStore: ObservableObject {
    private enum TokenKeys {
        static let access = "todo.accessToken"
        static let refresh = "todo.refreshToken"
    }

    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var currentSession: Session?

    private var modelContext: ModelContext
    private let api: APIHandler
    private let keychain = KeychainStore()

    init(modelContext: ModelContext, api: APIHandler) {
        self.modelContext = modelContext
        self.api = api
        let keychain = self.keychain
        Task {
            await api.setTokenProviders(
                access: {
                    keychain.read(TokenKeys.access)
                },
                refresh: {
                    keychain.read(TokenKeys.refresh)
                }
            )
        }
        loadSession()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadSession()
    }

    private func loadSession() {
        let descriptor = FetchDescriptor<Session>()
        guard let session = try? modelContext.fetch(descriptor).first else {
            clearSessionState()
            return
        }
        if let expiry = session.accessTokenExpiry, expiry <= Date() {
            purgeSessionData()
            return
        }
        guard keychain.read(session.accessTokenKey) != nil else {
            purgeSessionData()
            return
        }
        currentSession = session
        isLoggedIn = true
    }

    private func clearSessionState() {
        currentSession = nil
        isLoggedIn = false
    }

    private func purgeSessionData() {
        let existing = try? modelContext.fetch(FetchDescriptor<Session>())
        existing?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        keychain.delete(TokenKeys.access)
        keychain.delete(TokenKeys.refresh)
        clearSessionState()
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
        let req = LoginRequest(username: username, password: password, expiresInMins: 30)
        let resp: LoginResponse = try await api.request("/auth/login", method: "POST", body: req, authorized: false)

        let access = resp.accessToken ?? resp.token ?? ""
        guard !access.isEmpty else { throw APIError.unauthorized }

        try keychain.write(access, for: TokenKeys.access)
        if let refresh = resp.refreshToken {
            try keychain.write(refresh, for: TokenKeys.refresh)
        } else {
            keychain.delete(TokenKeys.refresh)
        }

        // Save session
        let session = Session(
            username: resp.username,
            email: resp.email,
            accessTokenKey: TokenKeys.access,
            refreshTokenKey: resp.refreshToken == nil ? nil : TokenKeys.refresh,
            accessTokenExpiry: resp.expiresInMins.flatMap { Date().addingTimeInterval(TimeInterval($0 * 60)) },
            userId: resp.id
        )
        // Clear existing sessions
        let existing = try? modelContext.fetch(FetchDescriptor<Session>())
        existing?.forEach { modelContext.delete($0) }
        modelContext.insert(session)
        try modelContext.save()

        currentSession = session
        isLoggedIn = true
    }

    func logout() {
        let existing = try? modelContext.fetch(FetchDescriptor<Session>())
        existing?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        keychain.delete(TokenKeys.access)
        keychain.delete(TokenKeys.refresh)
        currentSession = nil
        isLoggedIn = false
    }
}
