import Foundation
import SwiftData

@Model
final class Session {
    @Attribute(.unique) var id: UUID
    var username: String
    var email: String?
    var accessToken: String
    var refreshToken: String?
    var accessTokenExpiry: Date?
    var refreshTokenExpiry: Date?
    var userId: Int?

    init(
        id: UUID = UUID(),
        username: String,
        email: String? = nil,
        accessToken: String,
        refreshToken: String? = nil,
        accessTokenExpiry: Date? = nil,
        refreshTokenExpiry: Date? = nil,
        userId: Int? = nil
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpiry = accessTokenExpiry
        self.refreshTokenExpiry = refreshTokenExpiry
        self.userId = userId
    }
}
