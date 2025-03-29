import SwiftUI

class SignUpViewModel: ObservableObject {
    // MARK: - Published Variables
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isRegistered = false
    @Published var errorMessage: String?

    // MARK: - Form Validation
    var isFormValid: Bool {
        return ValidationService.isValidName(firstName) &&
               ValidationService.isValidName(lastName) &&
               ValidationService.isValidEmail(email) &&
               ValidationService.isValidPassword(password) &&
               password == confirmPassword
    }

    var passwordStrengthMessage: String {
        return ValidationService.passwordStrengthMessage(password) ?? "Strong password!"
    }

    var firstNameMessage: String? {
        ValidationService.nameValidationMessage(firstName)
    }

    var lastNameMessage: String? {
        ValidationService.nameValidationMessage(lastName)
    }

    var emailMessage: String? {
        ValidationService.emailValidationMessage(email)
    }

    var passwordMessage: String? {
        let message = ValidationService.passwordStrengthMessage(password)
        return message == "Strong password!" ? nil : message
    }

    var confirmPasswordMessage: String? {
        if confirmPassword.isEmpty { return "Please confirm your password." }
        if confirmPassword != password { return "Passwords do not match." }
        return nil
    }
    
    
    // MARK: - Sign Up Function
    func signUp(completion: @escaping (Bool) -> Void) {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        AuthService.shared.signUp(email: email, password: password, firstName: firstName, lastName: lastName) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isRegistered = true
                    completion(true)
                } else {
                    self.errorMessage = error
                    completion(false)
                }
            }
        }
    }
        
}
