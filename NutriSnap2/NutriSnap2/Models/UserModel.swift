import Foundation

struct UserModel: Codable, Identifiable {
    var id: String 
    var firstName: String
    var lastName: String
    var email: String
    var passwordHash: String
    var calorieGoal: Int?

    // MARK: - Initializer
    init(id: String = UUID().uuidString, firstName: String, lastName: String, email: String, password: String, calorieGoal: Int? = nil) {
        self.id = id 
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.passwordHash = SecurityManager.shared.hashPassword(password)
        self.calorieGoal = calorieGoal ?? 2000
    }
}
