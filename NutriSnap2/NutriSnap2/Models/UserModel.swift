import Foundation

struct UserModel: Identifiable, Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var hasSetGoal: Bool = false

    // Nutrition Goals
    var calorieGoal: Int = 2000
    var carbGrams: Double = 250.0
    var proteinGrams: Double = 125.0
    var fatGrams: Double = 56.0
    var selectedPreset: String? = nil

    // Meal-Specific Calorie Distribution
    var mealDistributionPreset: String? = nil
    var breakfastPercentage: Double = 25.0
    var lunchPercentage: Double = 35.0
    var dinnerPercentage: Double = 30.0
    var snackPercentage: Double = 10.0

    // MARK: - Preset Options for Macros
    static func macroGramsPreset(for calories: Int) -> [String: (Double, Double, Double)] {
        return [
            "Balanced (50/25/25)": (
                Double(calories) * 0.50 / 4,
                Double(calories) * 0.25 / 4,
                Double(calories) * 0.25 / 9
            ),
            "High-Protein (40/35/25)": (
                Double(calories) * 0.40 / 4,
                Double(calories) * 0.35 / 4,
                Double(calories) * 0.25 / 9
            ),
            "Keto (10/30/60)": (
                Double(calories) * 0.10 / 4,
                Double(calories) * 0.30 / 4,
                Double(calories) * 0.60 / 9
            ),
            "Low-Carb (30/35/35)": (
                Double(calories) * 0.30 / 4,
                Double(calories) * 0.35 / 4,
                Double(calories) * 0.35 / 9
            )
        ]
    }

    // MARK: - Preset Options for Meal Calorie Distribution
    static let mealPresets: [String: (Double, Double, Double, Double)] = [
        "Standard (25/35/30/10)": (25.0, 35.0, 30.0, 10.0),
        "Even Split (25/25/25/25)": (25.0, 25.0, 25.0, 25.0),
        "Big Breakfast (40/30/20/10)": (40.0, 30.0, 20.0, 10.0),
        "Big Dinner (20/30/40/10)": (20.0, 30.0, 40.0, 10.0)
    ]

    // MARK: - Firestore Data Conversion
    static func fromFirestore(id: String, data: [String: Any]) -> UserModel? {
        guard let firstName = data["firstName"] as? String,
              let lastName = data["lastName"] as? String,
              let email = data["email"] as? String else {
            print("Firestore data is missing required user fields")
            return nil
        }

        return UserModel(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            hasSetGoal: data["hasSetGoal"] as? Bool ?? false,
            calorieGoal: data["calorieGoal"] as? Int ?? 2000,
            carbGrams: data["carbGrams"] as? Double ?? 250.0,
            proteinGrams: data["proteinGrams"] as? Double ?? 125.0,
            fatGrams: data["fatGrams"] as? Double ?? 56.0,
            selectedPreset: data["selectedPreset"] as? String,
            mealDistributionPreset: data["mealDistributionPreset"] as? String,
            breakfastPercentage: data["breakfastPercentage"] as? Double ?? 25.0,
            lunchPercentage: data["lunchPercentage"] as? Double ?? 35.0,
            dinnerPercentage: data["dinnerPercentage"] as? Double ?? 30.0,
            snackPercentage: data["snackPercentage"] as? Double ?? 10.0
        )
    }

    func toFirestore() -> [String: Any] {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "hasSetGoal": hasSetGoal,
            "calorieGoal": calorieGoal,
            "carbGrams": carbGrams,
            "proteinGrams": proteinGrams,
            "fatGrams": fatGrams,
            "selectedPreset": selectedPreset as Any,
            "mealDistributionPreset": mealDistributionPreset as Any,
            "breakfastPercentage": breakfastPercentage,
            "lunchPercentage": lunchPercentage,
            "dinnerPercentage": dinnerPercentage,
            "snackPercentage": snackPercentage
        ]
    }

    // MARK: - Update Methods
    mutating func updateMacros(carbs: Double, protein: Double, fats: Double, preset: String) {
        self.carbGrams = carbs
        self.proteinGrams = protein
        self.fatGrams = fats
        self.selectedPreset = preset
    }

    mutating func updateMeals(breakfast: Double, lunch: Double, dinner: Double, snack: Double, preset: String) {
        self.breakfastPercentage = breakfast
        self.lunchPercentage = lunch
        self.dinnerPercentage = dinner
        self.snackPercentage = snack
        self.mealDistributionPreset = preset
    }

    func saveToFirestore(completion: @escaping (Bool) -> Void) {
        FirestoreService.shared.updateUserGoals(self, completion: completion)
    }
}
