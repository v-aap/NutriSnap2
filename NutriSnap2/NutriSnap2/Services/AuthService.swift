//
//  AuthService.swift
//  NutriSnap2
//
//  Created by Valeria Arce on 2025-03-18.
//

import FirebaseAuth
import FirebaseFirestore

class AuthService {
    static let shared = AuthService()
    private let db = Firestore.firestore()

    // MARK: - Sign Up Function
    func signUp(email: String, password: String, firstName: String, lastName: String, calorieGoal: Int?, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let user = authResult?.user else {
                completion(false, "User not found after signup.")
                return
            }

            // Default User Data with Embedded Goal
            let userData: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "calorieGoal": calorieGoal ?? 2000,  // Default 2000 kcal
                "carbPercentage": 50.0,
                "proteinPercentage": 25.0,
                "fatPercentage": 25.0,
                "selectedPreset": "Balanced (50/25/25)"
            ]

            // Store in Firestore
            self.db.collection("users").document(user.uid).setData(userData) { error in
                completion(error == nil, error?.localizedDescription)
            }
        }
    }

    // MARK: - Fetch User Nutrition Goals
    func fetchUserGoal(completion: @escaping (NutritionGoal?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        db.collection("users").document(userID).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                completion(nil)
                return
            }

            let goal = NutritionGoal(
                calorieGoal: data["calorieGoal"] as? Int ?? 2000,
                carbGrams: 0,
                proteinGrams: 0,
                fatGrams: 0,
                carbPercentage: data["carbPercentage"] as? Double ?? 50.0,
                proteinPercentage: data["proteinPercentage"] as? Double ?? 25.0,
                fatPercentage: data["fatPercentage"] as? Double ?? 25.0,
                isAutoCalculated: false,
                selectedPreset: data["selectedPreset"] as? String ?? "Balanced (50/25/25)"
            )

            completion(goal)
        }
    }

    // MARK: - Update User Goal
    func updateUserGoal(_ goal: NutritionGoal, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let goalData: [String: Any] = [
            "calorieGoal": goal.calorieGoal,
            "carbPercentage": goal.carbPercentage,
            "proteinPercentage": goal.proteinPercentage,
            "fatPercentage": goal.fatPercentage,
            "selectedPreset": goal.selectedPreset
        ]

        db.collection("users").document(userID).updateData(goalData) { error in
            completion(error == nil)
        }
    }
}
