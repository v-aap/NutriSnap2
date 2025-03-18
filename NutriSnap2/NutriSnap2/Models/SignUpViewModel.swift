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
