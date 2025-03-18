import Foundation

struct UserModel: Identifiable, Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var hasSetGoal: Bool = false

    // Nutrition Goals
    var calorieGoal: Int = 2000
    var carbPercentage: Double = 50.0
    var proteinPercentage: Double = 25.0
    var fatPercentage: Double = 25.0
    var selectedPreset: String = "Balanced (50/25/25)"

    // MARK: - Convert Firestore Data to UserModel
    static func fromFirestore(id: String, data: [String: Any]) -> UserModel? {
        guard let firstName = data["firstName"] as? String,
              let lastName = data["lastName"] as? String,
              let email = data["email"] as? String else {
            print("⚠️ Firestore data is missing required user fields!")
            return nil
        }

        return UserModel(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            hasSetGoal: data["hasSetGoal"] as? Bool ?? false,
            calorieGoal: data["calorieGoal"] as? Int ?? 2000,
            carbPercentage: data["carbPercentage"] as? Double ?? 50.0,
            proteinPercentage: data["proteinPercentage"] as? Double ?? 25.0,
            fatPercentage: data["fatPercentage"] as? Double ?? 25.0,
            selectedPreset: data["selectedPreset"] as? String ?? "Balanced (50/25/25)"
        )
    }

    // MARK: - Convert to Firestore Data
    func toFirestore() -> [String: Any] {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "hasSetGoal": hasSetGoal,
            "calorieGoal": calorieGoal,
            "carbPercentage": carbPercentage,
            "proteinPercentage": proteinPercentage,
            "fatPercentage": fatPercentage,
            "selectedPreset": selectedPreset
        ]
    }
}
