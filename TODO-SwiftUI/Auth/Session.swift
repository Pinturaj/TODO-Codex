import Foundation
import SwiftData

@Model
final class Session {
    @Attribute(.unique) var id: UUID
    var username: String
    var email: String?
    var accessTokenKey: String
    var refreshTokenKey: String?
    var accessTokenExpiry: Date?
    var refreshTokenExpiry: Date?
    var userId: Int?

    init(
        id: UUID = UUID(),
        username: String,
        email: String? = nil,
        accessTokenKey: String,
        refreshTokenKey: String? = nil,
        accessTokenExpiry: Date? = nil,
        refreshTokenExpiry: Date? = nil,
        userId: Int? = nil
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.accessTokenKey = accessTokenKey
        self.refreshTokenKey = refreshTokenKey
        self.accessTokenExpiry = accessTokenExpiry
        self.refreshTokenExpiry = refreshTokenExpiry
        self.userId = userId
    }
}
