//
//  FirestoneService.swift
//  NutriSnap2
//
//  Created by Valeria Arce on 2025-03-18.
//

import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    let db = Firestore.firestore()

    // Existing saveUser function
    func saveUser(userID: String, data: [String: Any], completion: @escaping (Bool) -> Void) {
        db.collection("users").document(userID).setData(data) { error in
            completion(error == nil)
        }
    }
    
    // New: Save Meal function
    func saveMeal(_ meal: MealEntry, completion: @escaping (Bool) -> Void) {
        let mealData: [String: Any] = [
            "userID": meal.userID,
            "date": meal.date,
            "foodName": meal.foodName,
            "calories": meal.calories,
            "carbs": meal.carbs,
            "protein": meal.protein,
            "fats": meal.fats,
            "isManualEntry": meal.isManualEntry,
            "mealType": meal.mealType,
            "photoURL": meal.photoURL ?? ""
        ]
        
        db.collection("meals").addDocument(data: mealData) { error in
            if let error = error {
                print("Error adding meal: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
