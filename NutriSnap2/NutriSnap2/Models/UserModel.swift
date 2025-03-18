import Foundation

struct UserModel: Identifiable, Codable {
    var id: String  
    var firstName: String
    var lastName: String
    var email: String
    var hasSetGoal: Bool

    // Nutrition Goals
    var calorieGoal: Int
    var carbPercentage: Double
    var proteinPercentage: Double
    var fatPercentage: Double
    var selectedPreset: String

    // MARK: - Default Initializer
    init(id: String, firstName: String, lastName: String, email: String, hasSetGoal: Bool = false,
         calorieGoal: Int = 2000, carbPercentage: Double = 50.0, proteinPercentage: Double = 25.0, fatPercentage: Double = 25.0,
         selectedPreset: String = "Balanced (50/25/25)") {
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.hasSetGoal = hasSetGoal
        self.calorieGoal = calorieGoal
        self.carbPercentage = carbPercentage
        self.proteinPercentage = proteinPercentage
        self.fatPercentage = fatPercentage
        self.selectedPreset = selectedPreset
    }

    // MARK: - Convert Firestore Data to UserModel
    static func fromFirestore(id: String, data: [String: Any]) -> UserModel? {
        guard let firstName = data["firstName"] as? String,
              let lastName = data["lastName"] as? String,
              let email = data["email"] as? String else {
            print("⚠️ Firestore data is missing required user fields!")
            return nil
        }

        let hasSetGoal = data["hasSetGoal"] as? Bool ?? false
        let calorieGoal = data["calorieGoal"] as? Int ?? 2000
        let carbPercentage = data["carbPercentage"] as? Double ?? 50.0
        let proteinPercentage = data["proteinPercentage"] as? Double ?? 25.0
        let fatPercentage = data["fatPercentage"] as? Double ?? 25.0
        let selectedPreset = data["selectedPreset"] as? String ?? "Balanced (50/25/25)"

        return UserModel(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            hasSetGoal: hasSetGoal,
            calorieGoal: calorieGoal,
            carbPercentage: carbPercentage,
            proteinPercentage: proteinPercentage,
            fatPercentage: fatPercentage,
            selectedPreset: selectedPreset
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
