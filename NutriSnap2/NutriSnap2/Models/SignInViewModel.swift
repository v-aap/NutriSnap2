import SwiftUI

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated = false
    @Published var currentUser: UserModel? // Stores logged-in user

    func signIn() {
        MongoDBManager.shared.loginUser(email: email, password: password) { user in
            DispatchQueue.main.async {
                if let user = user {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.saveUserSession(user: user) // Store user locally
                } else {
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

    // MARK: - Load Stored User
    func loadUserSession() {
        if let savedUser = UserDefaults.standard.data(forKey: "loggedInUser"),
           let decodedUser = try? JSONDecoder().decode(UserModel.self, from: savedUser) {
            self.currentUser = decodedUser
            self.isAuthenticated = true
        }
    }

    // MARK: - Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: "loggedInUser")
        self.currentUser = nil
        self.isAuthenticated = false
    }
}
