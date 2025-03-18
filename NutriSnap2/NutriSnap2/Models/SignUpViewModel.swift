import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isRegistered = false
    @Published var errorMessage: String?

    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }

    // MARK: - Sign Up Function
    func signUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        AuthService.shared.signUp(email: email, password: password, firstName: firstName, lastName: lastName) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isRegistered = true
                } else {
                    self.errorMessage = error
                }
            }
        }
    }
}
