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

    // MARK: - Sign Up Function (Stores Basic User Data in Firestore)
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

            // Create UserModel
            let newUser = UserModel(
                id: user.uid,
                firstName: firstName,
                lastName: lastName,
                email: email
            )

            // Store in Firestore
            self.db.collection("users").document(user.uid).setData(newUser.toFirestore()) { error in
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

    // MARK: - Fetch User Data
    func fetchUserData(completion: @escaping (UserModel?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        db.collection("users").document(userID).getDocument { snapshot, error in
            guard let document = snapshot, document.exists, let data = document.data() else {
                completion(nil)
                return
            }

            let user = UserModel.fromFirestore(id: userID, data: data)
            completion(user)
        }
    }

    // MARK: - Check if User Has a Nutrition Goal
    func checkIfUserHasGoal(completion: @escaping (Bool) -> Void) {
        fetchUserData { user in
            completion(user?.hasSetGoal ?? false)
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
            "hasSetGoal": true  // Mark user as having set their goal
        ]

        db.collection("users").document(userID).updateData(goalData) { error in
            completion(error == nil)
        }
    }

    // MARK: - Sign Out Function
    func signOut(completion: @escaping (Bool, String?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true, nil)
        } catch let signOutError {
            completion(false, signOutError.localizedDescription)
        }
    }
}
