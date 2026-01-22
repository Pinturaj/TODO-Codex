import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case decodingFailed
    case unauthorized
    case refreshUnavailable
    case server(status: Int)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .decodingFailed: return "Failed to decode response"
        case .unauthorized: return "Unauthorized"
        case .refreshUnavailable: return "Refresh token not available"
        case .server(let status): return "Server error \(status)"
        case .transport(let e): return "Network error: \(e.localizedDescription)"
        }
    }
}
