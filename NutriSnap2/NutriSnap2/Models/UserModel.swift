import Foundation

struct UserModel: Codable, Identifiable {
    var id: String = UUID().uuidString
    var firstName: String
    var lastName: String
    var email: String
    var passwordHash: String // ⚠️ Store hashed password, not plaintext
    var calorieGoal: Int?

    // MARK: - Initializer
    init(firstName: String, lastName: String, email: String, password: String, calorieGoal: Int? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.passwordHash = SecurityManager.shared.hashPassword(password) // ✅ Hash password
        self.calorieGoal = calorieGoal ?? 2000 // Default calorie goal if none is set
    }
}
