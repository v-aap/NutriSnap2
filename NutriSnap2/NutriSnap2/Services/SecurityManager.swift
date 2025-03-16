import CryptoKit

class SecurityManager {
    static let shared = SecurityManager()

    /// Hashes a password using SHA-256.
    func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
