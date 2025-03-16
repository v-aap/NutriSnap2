import RealmSwift

class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false

    func signIn() {
        let app = App(id: "your-realm-app-id") // 🔹 Replace with your MongoDB Realm App ID
        
        app.login(credentials: Credentials.emailPassword(email: email, password: password)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("Login successful for: \(user.id)")
                    self.isAuthenticated = true
                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
