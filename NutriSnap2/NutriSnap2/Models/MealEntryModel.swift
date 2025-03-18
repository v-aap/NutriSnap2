import Foundation
import FirebaseFirestore

// MARK: - Meal Type Enum
enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}

// MARK: - MealEntry Model
struct MealEntry: Identifiable, Codable {
    var id: UUID
    var userID: String
    var date: Date
    var foodName: String
    var calories: Int
    var carbs: Int
    var protein: Int
    var fats: Int
    var isManualEntry: Bool
    var mealType: MealType
    var photoURL: String?

    // Default Initializer
    init(id: UUID = UUID(), userID: String, date: Date, foodName: String, calories: Int, carbs: Int, protein: Int, fats: Int, isManualEntry: Bool, mealType: MealType, photoURL: String? = nil) {
        self.id = id
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

    // MARK: - Convert Firestore Data to MealEntry
    static func fromFirestore(id: String, data: [String: Any]) -> MealEntry? {
        guard let userID = data["userID"] as? String,
              let timestamp = data["date"] as? Timestamp,
              let foodName = data["foodName"] as? String,
              let calories = data["calories"] as? Int,
              let carbs = data["carbs"] as? Int,
              let protein = data["protein"] as? Int,
              let fats = data["fats"] as? Int,
              let isManualEntry = data["isManualEntry"] as? Bool,
              let mealTypeRaw = data["mealType"] as? String,
              let mealType = MealType(rawValue: mealTypeRaw) else {
            return nil
        }

        return MealEntry(
            id: UUID(uuidString: id) ?? UUID(),
            userID: userID,
            date: timestamp.dateValue(),
            foodName: foodName,
            calories: calories,
            carbs: carbs,
            protein: protein,
            fats: fats,
            isManualEntry: isManualEntry,
            mealType: mealType,
            photoURL: data["photoURL"] as? String
        )
    }

    // MARK: - Convert to Firestore Format
    func toFirestore() -> [String: Any] {
        return [
            "userID": userID,
            "date": Timestamp(date: date),
            "foodName": foodName,
            "calories": calories,
            "carbs": carbs,
            "protein": protein,
            "fats": fats,
            "isManualEntry": isManualEntry,
            "mealType": mealType.rawValue, 
            "photoURL": photoURL ?? ""
        ]
    }
}
