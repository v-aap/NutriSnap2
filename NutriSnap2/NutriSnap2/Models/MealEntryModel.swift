import Foundation
import RealmSwift

class MealEntry: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId = ObjectId.generate()
    @Persisted var date: Date
    @Persisted var foodName: String
    @Persisted var calories: Int
    @Persisted var carbs: Int
    @Persisted var protein: Int
    @Persisted var fats: Int
    @Persisted var isManualEntry: Bool
    @Persisted var mealType: String

    static let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    // Explicit initializer
    convenience init(date: Date, foodName: String, calories: Int, carbs: Int, protein: Int, fats: Int, isManualEntry: Bool, mealType: String) {
        self.init()
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
