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
                completion(false, ErrorHandlingService.getAuthErrorMessage(error))
                return
            }

            guard let user = authResult?.user else {
                completion(false, "User not found after signup.")
                return
            }

            let newUser = UserModel(id: user.uid, firstName: firstName, lastName: lastName, email: email)
            FirestoreService.shared.saveUser(userID: user.uid, data: newUser.toFirestore()) { success in
                completion(success, success ? nil : "Failed to store user data.")
            }
        }
    }

    // MARK: - Sign In Function
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, ErrorHandlingService.getAuthErrorMessage(error))
                return
            }
            completion(true, nil)
        }
    }

    // MARK: - Forgot Password Function
    func resetPassword(email: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false, ErrorHandlingService.getAuthErrorMessage(error))
            } else {
                completion(true, "Password reset email has been sent.")
            }
        }
    }

    // MARK: - Sign Out Function
    func signOut(completion: @escaping (Bool, String?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true, nil)
        } catch let error {
            completion(false, ErrorHandlingService.getSystemErrorMessage(error))
        }
    }

    // MARK: - Check if User is Logged In
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }

    // MARK: - Get Current User ID
    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
