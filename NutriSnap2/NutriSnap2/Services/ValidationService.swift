//
//  ValidationService.swift
//  NutriSnap2
//
//  Created by Valeria Arce on 2025-03-18.
//

import Foundation

class ValidationService {
    
    // MARK: - Name Validation (Only Letters & Spaces)
    static func isValidName(_ name: String) -> Bool {
        let regex = "^[A-Za-z]+(?: [A-Za-z]+)*$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: name)
    }
    
    static func nameValidationMessage(_ name: String) -> String? {
        if name.isEmpty {
            return "Name cannot be empty."
        }
        if !isValidName(name) {
            return "Name must contain only letters and spaces."
        }
        return nil
    }

    // MARK: - Email Validation
    static func isValidEmail(_ email: String) -> Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    static func emailValidationMessage(_ email: String) -> String? {
        if email.isEmpty {
            return "Email cannot be empty."
        }
        if !isValidEmail(email) {
            return "Invalid email format."
        }
        return nil
    }

    // MARK: - Password Strength Validation
    static func isValidPassword(_ password: String) -> Bool {
        let regex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

    static func passwordStrengthMessage(_ password: String) -> String? {
        if password.isEmpty { return "Password cannot be empty." }
        if password.count < 8 { return "Password must be at least 8 characters long." }
        if !password.contains(where: { $0.isUppercase }) { return "Must contain at least one uppercase letter." }
        if !password.contains(where: { $0.isLowercase }) { return "Must contain at least one lowercase letter." }
        if !password.contains(where: { $0.isNumber }) { return "Must contain at least one number." }
        if !password.contains(where: { "!@#$%^&*()_+=-".contains($0) }) { return "Must contain at least one special character." }
        return "Strong password!"
    }
}
