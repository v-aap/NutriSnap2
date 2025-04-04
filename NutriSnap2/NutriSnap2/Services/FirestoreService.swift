//
//  FirestoreService.swift
//  NutriSnap2
//
//  Created by Valeria Arce on 2025-03-18.
//

import FirebaseFirestore
import FirebaseAuth

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

    // MARK: - Update User Goals (Macronutrients + Meal Distribution)
    // MARK: - Update User Goals (Macronutrients in grams + Meal Distribution)
    func updateUserGoals(_ goal: UserModel, completion: @escaping (Bool) -> Void) {
        guard let userID = AuthService.shared.getCurrentUserID() else {
            completion(false)
            return
        }

        let goalData: [String: Any] = [
            "calorieGoal": goal.calorieGoal,
            "carbGrams": goal.carbGrams,
            "proteinGrams": goal.proteinGrams,
            "fatGrams": goal.fatGrams,
            "selectedPreset": goal.selectedPreset as Any,
            "mealDistributionPreset": goal.mealDistributionPreset as Any,
            "breakfastPercentage": goal.breakfastPercentage,
            "lunchPercentage": goal.lunchPercentage,
            "dinnerPercentage": goal.dinnerPercentage,
            "snackPercentage": goal.snackPercentage,
            "hasSetGoal": true
        ]

        db.collection("users").document(userID).updateData(goalData) { error in
            if let error = error {
                print("❌ Error updating user goals: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ User goals updated successfully.")
                completion(true)
            }
        }
    }


    // MARK: - Update User Profile (Name, Email)
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

    // MARK: Save Meal Function
    func saveMeal(meal: MealEntry, completion: @escaping (Bool, String?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false, "User not authenticated.")
            return
        }

        let mealData = meal.toFirestore()

        db.collection("meals").document(meal.id.uuidString).setData(mealData) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }

    // MARK: - Fetch Meals (For Logged-in User)
    func fetchMeals(completion: @escaping ([MealEntry]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        db.collection("meals")
            .whereField("userID", isEqualTo: userID)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching meals: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let meals = snapshot?.documents.compactMap { doc -> MealEntry? in
                    let data = doc.data()
                    return MealEntry.fromFirestore(id: doc.documentID, data: data)
                } ?? []
                completion(meals)
            }
    }

    // MARK: - Delete Meal Entry
    func deleteMealEntry(mealID: String, completion: @escaping (Bool) -> Void) {
        db.collection("meals").document(mealID).delete { error in
            if let error = error {
                print("❌ Error deleting meal: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Meal deleted successfully.")
                completion(true)
            }
        }
    }
    
    // MARK: - Save Favorite Meal
    func saveFavoriteMeal(_ meal: FavoriteMeal, completion: @escaping (Bool, String?) -> Void) {
        let mealData = meal.toFirestore()
        db.collection("favorites").document(meal.id.uuidString).setData(mealData) { error in
            if let error = error {
                print("❌ Error saving favorite meal: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            } else {
                print("✅ Favorite meal saved successfully.")
                completion(true, nil)
            }
        }
    }

    // MARK: - Fetch Favorite Meals (For Logged-in User)
    func fetchFavoriteMeals(completion: @escaping ([FavoriteMeal]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        db.collection("favorites")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching favorite meals: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let favorites = snapshot?.documents.compactMap { doc in
                    FavoriteMeal.fromFirestore(id: doc.documentID, data: doc.data())
                } ?? []

                completion(favorites)
            }
    }

    // MARK: - Delete Favorite Meal (Optional)
    func deleteFavoriteMeal(favoriteID: UUID, completion: @escaping (Bool) -> Void) {
        db.collection("favorites").document(favoriteID.uuidString).delete { error in
            if let error = error {
                print("❌ Error deleting favorite meal: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Favorite meal deleted successfully.")
                completion(true)
            }
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
