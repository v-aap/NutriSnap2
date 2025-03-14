import Foundation

struct NutritionGoal: Codable {
    var calorieGoal: Int
    var carbGrams: Int
    var proteinGrams: Int
    var fatGrams: Int
    var carbPercentage: Double
    var proteinPercentage: Double
    var fatPercentage: Double
    var isAutoCalculated: Bool
    var selectedPreset: String

    // MARK: - Default Values
    static let defaultGoal = NutritionGoal(
        calorieGoal: 2000,
        carbGrams: 250,
        proteinGrams: 125,
        fatGrams: 56,
        carbPercentage: 50,
        proteinPercentage: 25,
        fatPercentage: 25,
        isAutoCalculated: false,
        selectedPreset: "Balanced (50/25/25)"
    )
    
    // MARK: - Auto Calculation Method
    mutating func calculateMacros() {
        let carbCalories = Double(calorieGoal) * (carbPercentage / 100)
        let proteinCalories = Double(calorieGoal) * (proteinPercentage / 100)
        let fatCalories = Double(calorieGoal) * (fatPercentage / 100)
        
        self.carbGrams = Int(carbCalories / 4)  // 1g carb = 4 kcal
        self.proteinGrams = Int(proteinCalories / 4)  // 1g protein = 4 kcal
        self.fatGrams = Int(fatCalories / 9)  // 1g fat = 9 kcal
    }
    
    // MARK: - Preset Macros
    mutating func applyPreset(_ preset: String) {
        let presets: [String: (Double, Double, Double)] = [
            "Balanced (50/25/25)": (50, 25, 25),
            "High-Protein (40/35/25)": (40, 35, 25),
            "Low-Carb (30/35/35)": (30, 35, 35),
            "Keto (10/30/60)": (10, 30, 60)
        ]
        
        if let (carb, protein, fat) = presets[preset] {
            self.carbPercentage = carb
            self.proteinPercentage = protein
            self.fatPercentage = fat
            self.selectedPreset = preset
            calculateMacros()
        }
    }
}
