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
    func signUp(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let user = authResult?.user else {
                completion(false, "User not found after signup.")
                return
            }

            // Store only identity information at signup
            let userData: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "hasSetGoal": false  
            ]

            self.db.collection("users").document(user.uid).setData(userData) { error in
                completion(error == nil, error?.localizedDescription)
            }
        }
    }

    // MARK: - Sign In Function 
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            completion(true, nil)
        }
    }

    // MARK: - Check if User Has a Nutrition Goal
    func checkIfUserHasGoal(completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        db.collection("users").document(userID).getDocument { snapshot, error in
            if let data = snapshot?.data(), let hasSetGoal = data["hasSetGoal"] as? Bool {
                completion(hasSetGoal)
            } else {
                completion(false)
            }
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
            "selectedPreset": goal.selectedPreset,
            "hasSetGoal": true  
        ]

        db.collection("users").document(userID).updateData(goalData) { error in
            completion(error == nil)
        }
    }
}
