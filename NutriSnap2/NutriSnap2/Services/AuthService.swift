//
//  AuthService.swift
//  NutriSnap2
//
//  Created by Valeria Arce on 2025-03-18.
//

import FirebaseAuth

class AuthService {
    static let shared = AuthService()

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

            // Optionally store user data in Firestore
            let userData: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "email": email
            ]
            FirestoreService.shared.saveUser(userID: user.uid, data: userData) { success in
                completion(success, nil)
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

    // MARK: - Logout Function
    func logout(completion: @escaping (Bool, String?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true, nil)
        } catch let signOutError {
            completion(false, signOutError.localizedDescription)
        }
    }
}
