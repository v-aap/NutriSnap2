import SwiftUI
import RealmSwift

class SignUpViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var dailyCalorieGoal: Int? = nil

    @Published var isRegistered = false

    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }

    // MARK: - Sign Up Function
    func signUp() async {
        guard password == confirmPassword else {
            print("Passwords do not match")
            return
        }

        let app = App(id: "nutrisnap-uaftlyk")

        do {
            try await app.emailPasswordAuth.registerUser(email: email, password: password)
            print("Registration successful!")

            // Auto-login after registration
            let success = await loginUser()
            
            if success {
                await saveUserToDatabase()
                DispatchQueue.main.async {
                    self.isRegistered = true
                }
            }
        } catch {
            print("Registration failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Login User After Registration
    func loginUser() async -> Bool {
        let app = App(id: "nutrisnap-uaftlyk")

        do {
            let credentials = Credentials.emailPassword(email: email, password: password)
            let user = try await app.login(credentials: credentials)
            print("Login successful for: \(user.id)")
            return true
        } catch {
            print("Login failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Save User to Database
    func saveUserToDatabase() async {
        let userModel = UserModel(
            firstName: firstName,
            lastName: lastName,
            email: email,
            dailyCalorieGoal: dailyCalorieGoal
        )

        let user = App(id: "nutrisnap-uaftlyk").currentUser
        if let user = user {
            let realm = try! await Realm(configuration: user.flexibleSyncConfiguration())
            try! realm.write {
                realm.add(userModel)
            }
            print("User data saved to MongoDB Realm")
        }
    }
}
