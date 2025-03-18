import SwiftUI

class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var errorMessage: String?

    // MARK: - Sign In Function
    func signIn() {
        AuthService.shared.signIn(email: email, password: password) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                } else {
                    self.errorMessage = error
                }
            }
        }
    }

    // MARK: - Logout Function
    func logout() {
        AuthService.shared.logout { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = false
                    self.email = ""
                    self.password = ""
                } else {
                    self.errorMessage = error
                }
            }
        }
    }
}
