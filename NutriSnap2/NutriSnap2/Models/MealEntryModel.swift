import Foundation

struct MealEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var userID: String  
    var date: Date
    var foodName: String
    var calories: Int
    var carbs: Int
    var protein: Int
    var fats: Int
    var isManualEntry: Bool
    var mealType: String
    var photoURL: String? 

    static let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    init(userID: String, date: Date, foodName: String, calories: Int, carbs: Int, protein: Int, fats: Int, isManualEntry: Bool, mealType: String, photoURL: String? = nil) {
        self.userID = userID
        self.date = date
        self.foodName = foodName
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fats = fats
        self.isManualEntry = isManualEntry
        self.mealType = mealType
        self.photoURL = photoURL
    }
}
