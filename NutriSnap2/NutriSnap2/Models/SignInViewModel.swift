import SwiftUI

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated = false

    func signIn() {
        MongoDBManager.shared.loginUser(email: email, password: password) { success in
            DispatchQueue.main.async {
                self.isAuthenticated = success
            }
        }
    }

// add function for forgot password
    
}
