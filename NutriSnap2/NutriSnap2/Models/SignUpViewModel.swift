//
//  SignUpViewModel.swift
//  NutriSnap
//
//  Created by Oscar Piedrasanta Diaz on 2025-03-01.
//


import SwiftUI
import Combine

class SignUpViewModel: ObservableObject {
    // MARK: - Published Properties for User Input
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var dailyCalorieGoal: String = ""
    
    
    // MARK: - Sign Up Action
    func signUp() {
        print("Signing up with:")
        print("First Name: \(firstName)")
        print("Last Name: \(lastName)")
        print("Email: \(email)")
        print("Password: \(password)")
        print("Confirm Password: \(confirmPassword)")
        print("Daily Calorie Goal: \(dailyCalorieGoal)")
    }
}
