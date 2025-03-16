import SwiftUI
import RealmSwift

class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var isAuthenticated = false
    @Published var currentUser: UserModel?

    // MARK: - Sign In Function
    func signIn() async {
        let app = App(id: "nutrisnap-uaftlyk") 
        
        do {
            let credentials = Credentials.emailPassword(email: email, password: password)
            let user = try await app.login(credentials: credentials)
            print("Login successful for: \(user.id)")
            self.isAuthenticated = true

            // Fetch user details after login
            await fetchUserProfile()
        } catch {
            print("Login failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch User Profile from Realm
    func fetchUserProfile() async {
        let user = App(id: "nutrisnap-uaftlyk").currentUser
        if let user = user {
            let realm = try! await Realm(configuration: user.flexibleSyncConfiguration())
            if let userData = realm.objects(UserModel.self).where({ $0.email == email }).first {
                DispatchQueue.main.async {
                    self.firstName = userData.firstName
                    self.lastName = userData.lastName
                    self.currentUser = userData
                    print("Fetched User: \(self.firstName) \(self.lastName)")
                }
            }
        }
    }

    // MARK: - Logout Function
    func logout() async {
        let app = App(id: "nutrisnap-uaftlyk")
        if let user = app.currentUser {
            do {
                try await user.logOut()
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    self.currentUser = nil
                    self.email = ""
                    self.password = ""
                }
                print("User logged out successfully")
            } catch {
                print("Logout failed: \(error.localizedDescription)")
            }
        }
    }
}
