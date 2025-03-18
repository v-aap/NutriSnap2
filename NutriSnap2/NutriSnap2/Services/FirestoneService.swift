//
//  FirestoreService.swift
//  NutriSnap2
//
//  Created by Valeria Arce on 2025-03-18.
//

import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    // MARK: - Save User Data
    func saveUser(userID: String, data: [String: Any], completion: @escaping (Bool) -> Void) {
        db.collection("users").document(userID).setData(data) { error in
            if let error = error {
                print("❌ Firestore Error: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ User data saved successfully.")
                completion(true)
            }
        }
    }

    // MARK: - Fetch User Data
    func fetchUserData(completion: @escaping (UserModel?) -> Void) {
        guard let userID = AuthService.shared.getCurrentUserID() else {
            completion(nil)
            return
        }

        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Firestore Fetch Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = snapshot?.data(), let user = UserModel.fromFirestore(id: userID, data: data) {
                completion(user)
            } else {
                print("⚠️ No user data found in Firestore.")
                completion(nil)
            }
        }
    }

    // MARK: - Update User Goal
    func updateUserGoal(_ goal: NutritionGoal, completion: @escaping (Bool) -> Void) {
        guard let userID = AuthService.shared.getCurrentUserID() else {
            completion(false)
            return
        }

        let goalData: [String: Any] = [
            "calorieGoal": goal.calorieGoal,
            "carbPercentage": goal.carbPercentage,
            "proteinPercentage": goal.proteinPercentage,
            "fatPercentage": goal.fatPercentage,
            "selectedPreset": goal.selectedPreset,
            "hasSetGoal": true
        ]

        db.collection("users").document(userID).updateData(goalData) { error in
            if let error = error {
                print("❌ Error updating user goal: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ User goal updated successfully.")
                completion(true)
            }
        }
    }

    // MARK: - Update User Profile
    func updateUserProfile(firstName: String, lastName: String, email: String, completion: @escaping (Bool) -> Void) {
        guard let userID = AuthService.shared.getCurrentUserID() else {
            completion(false)
            return
        }

        let updatedData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email
        ]

        db.collection("users").document(userID).updateData(updatedData) { error in
            if let error = error {
                print("❌ Error updating profile: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Profile updated successfully.")
                completion(true)
            }
        }
    }

//    // MARK: - Save Meal Entry
//    func saveMealEntry(meal: MealEntry, completion: @escaping (Bool) -> Void) {
//        db.collection("meals").document(meal.id.uuidString).setData(meal.toFirestore()) { error in
//            if let error = error {
//                print("❌ Error saving meal entry: \(error.localizedDescription)")
//                completion(false)
//            } else {
//                print("✅ Meal entry saved successfully.")
//                completion(true)
//            }
//        }
//    }
//
//    // MARK: - Fetch Meals
//    func fetchMeals(completion: @escaping ([MealEntry]) -> Void) {
//        guard let userID = AuthService.shared.getCurrentUserID() else {
//            completion([])
//            return
//        }
//
//        db.collection("meals")
//            .whereField("userID", isEqualTo: userID)
//            .order(by: "date", descending: true)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ Error fetching meals: \(error.localizedDescription)")
//                    completion([])
//                    return
//                }
//
//                let meals = snapshot?.documents.compactMap { doc -> MealEntry? in
//                    let data = doc.data()
//                    return MealEntry.fromFirestore(id: doc.documentID, data: data)
//                } ?? []
//                completion(meals)
//            }
//    }
//
//    // MARK: - Delete Meal Entry
//    func deleteMealEntry(mealID: String, completion: @escaping (Bool) -> Void) {
//        db.collection("meals").document(mealID).delete { error in
//            if let error = error {
//                print("❌ Error deleting meal: \(error.localizedDescription)")
//                completion(false)
//            } else {
//                print("✅ Meal deleted successfully.")
//                completion(true)
//            }
//        }
//    }
}
