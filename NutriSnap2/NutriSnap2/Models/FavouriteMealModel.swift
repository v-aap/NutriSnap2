//
//  FavouriteMealModel.swift
//  NutriSnap2
//
//  Created by Valeria Arce on 2025-03-29.
//

import Foundation
import FirebaseFirestore

// MARK: - FavoriteMeal Model
struct FavoriteMeal: Identifiable, Codable {
    var id: UUID
    var userID: String
    var foodName: String
    var calories: Int
    var carbs: Int
    var protein: Int
    var fats: Int
    var mealType: MealType
    var photoURL: String?
    
    // Initializer
    init(id: UUID = UUID(), userID: String, foodName: String, calories: Int, carbs: Int, protein: Int, fats: Int, mealType: MealType, photoURL: String? = nil) {
        self.id = id
        self.userID = userID
        self.foodName = foodName
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fats = fats
        self.mealType = mealType
        self.photoURL = photoURL
    }
    
    
    
    // MARK: - Convert Firestore Data to FavoriteMeal
    static func fromFirestore(id: String, data: [String: Any]) -> FavoriteMeal? {
        guard let userID = data["userID"] as? String,
              let foodName = data["foodName"] as? String,
              let calories = data["calories"] as? Int,
              let carbs = data["carbs"] as? Int,
              let protein = data["protein"] as? Int,
              let fats = data["fats"] as? Int,
              let mealTypeRaw = data["mealType"] as? String,
              let mealType = MealType(rawValue: mealTypeRaw) else {
            return nil
        }
        
        return FavoriteMeal(
            id: UUID(uuidString: id) ?? UUID(),
            userID: userID,
            foodName: foodName,
            calories: calories,
            carbs: carbs,
            protein: protein,
            fats: fats,
            mealType: mealType,
            photoURL: data["photoURL"] as? String
        )
    }
    
    // MARK: - Convert to Firestore Format
    func toFirestore() -> [String: Any] {
        return [
            "userID": userID,
            "foodName": foodName,
            "calories": calories,
            "carbs": carbs,
            "protein": protein,
            "fats": fats,
            "mealType": mealType.rawValue,
            "photoURL": photoURL ?? ""
        ]
    }
}
    // MARK: - Matching Helper
    extension FavoriteMeal {
        func isSame(as meal: MealEntry) -> Bool {
            return self.userID == meal.userID &&
                   self.foodName == meal.foodName &&
                   self.calories == meal.calories &&
                   self.carbs == meal.carbs &&
                   self.protein == meal.protein &&
                   self.fats == meal.fats &&
                   self.mealType == meal.mealType
        }
    }

