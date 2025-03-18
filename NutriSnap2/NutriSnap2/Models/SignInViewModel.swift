import SwiftUI

class SignInViewModel: ObservableObject {
    // MARK: - Published Variables
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var errorMessage: String?

    // MARK: - Form Validation
    var isFormValid: Bool {
        return ValidationService.isValidEmail(email) && !password.isEmpty
    }

    // MARK: - Sign In Function
    func signIn(completion: @escaping (Bool) -> Void) {
        AuthService.shared.signIn(email: email, password: password) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ User successfully signed in: \(self.email)")
                    self.isAuthenticated = true
                } else {
                    print("❌ Sign-in failed: \(error ?? "Unknown error")")
                    self.errorMessage = error
                }
                completion(success)
            }
        }
    }
}
