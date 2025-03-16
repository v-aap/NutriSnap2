import SwiftUI

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated = false
    @Published var currentUser: UserModel? // Stores logged-in user

    func signIn() {
        Task {
            if let user = await MongoDBManager.shared.loginUser(email: email, password: password) {
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true // ✅ Trigger navigation
                    self.saveUserSession(user: user)
                }
            } else {
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                }
            }
        }
    }

    // MARK: - Store User Session
    private func saveUserSession(user: UserModel) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: "loggedInUser")
        }
    }
}
