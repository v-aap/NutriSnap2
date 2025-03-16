//
//  SignUpViewModel.swift
//  NutriSnap
//
//  Created by Oscar Piedrasanta Diaz on 2025-03-01.
//

import SwiftUI
import Combine

import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var dailyCalorieGoal: String = "2000"
    @Published var isRegistered = false

    func signUp() {
        guard password == confirmPassword else {
            print("❌ Passwords do not match")
            return
        }

        let user = UserModel(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            calorieGoal: Int(dailyCalorieGoal)
        )

        MongoDBManager.shared.registerUser(user: user) { success in
            DispatchQueue.main.async {
                self.isRegistered = success
            }
        }
    }
}

