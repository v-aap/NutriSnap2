import Foundation

struct MealEntry {
    var id = UUID()
    var date: Date
    var foodName: String
    var calories: Int
    var carbs: Int
    var protein: Int
    var fats: Int
    var isManualEntry: Bool
    var mealType: String

    static let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    // Explicit initializer
    init(date: Date, foodName: String, calories: Int, carbs: Int, protein: Int, fats: Int, isManualEntry: Bool, mealType: String) {
        self.date = date
        self.foodName = foodName
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fats = fats
        self.isManualEntry = isManualEntry
        self.mealType = mealType
    }
}
