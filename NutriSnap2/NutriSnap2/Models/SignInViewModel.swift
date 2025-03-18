import SwiftUI

class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var errorMessage: String?

    // MARK: - Sign In Function
    func signIn(completion: @escaping (Bool) -> Void) {
        AuthService.shared.signIn(email: email, password: password) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ User successfully signed in: \(self.email)")
                    AuthService.shared.fetchUserData { user in
                        if let user = user {
                            print("📌 User Data: \(user)")
                        } else {
                            print("❌ Failed to fetch user data")
                        }
                    }
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
