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
    var selectedPreset: String? = nil  // Allows user to override preset

    // Meal-Specific Calorie Distribution
    var mealDistributionPreset: String? = nil // Allows user-defined meal distribution
    var breakfastPercentage: Double = 25.0
    var lunchPercentage: Double = 35.0
    var dinnerPercentage: Double = 30.0
    var snackPercentage: Double = 10.0

    // MARK: - Preset Options for Macros
    static let macroPresets: [String: (Double, Double, Double)] = [
        "Balanced (50/25/25)": (50.0, 25.0, 25.0),
        "High-Protein (40/35/25)": (40.0, 35.0, 25.0),
        "Keto (10/30/60)": (10.0, 30.0, 60.0),
        "Low-Carb (30/35/35)": (30.0, 35.0, 35.0)
    ]
    
    // MARK: - Preset Options for Meal Calorie Distribution
    static let mealPresets: [String: (Double, Double, Double, Double)] = [
        "Standard (25/35/30/10)": (25.0, 35.0, 30.0, 10.0),
        "Even Split (25/25/25/25)": (25.0, 25.0, 25.0, 25.0),
        "Big Breakfast (40/30/20/10)": (40.0, 30.0, 20.0, 10.0),
        "Big Dinner (20/30/40/10)": (20.0, 30.0, 40.0, 10.0)
    ]

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
            selectedPreset: data["selectedPreset"] as? String,
            mealDistributionPreset: data["mealDistributionPreset"] as? String,
            breakfastPercentage: data["breakfastPercentage"] as? Double ?? 25.0,
            lunchPercentage: data["lunchPercentage"] as? Double ?? 35.0,
            dinnerPercentage: data["dinnerPercentage"] as? Double ?? 30.0,
            snackPercentage: data["snackPercentage"] as? Double ?? 10.0
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
            "selectedPreset": selectedPreset as Any, // Allow nil for custom values
            "mealDistributionPreset": mealDistributionPreset as Any, // Allow nil for custom values
            "breakfastPercentage": breakfastPercentage,
            "lunchPercentage": lunchPercentage,
            "dinnerPercentage": dinnerPercentage,
            "snackPercentage": snackPercentage
        ]
    }
}
