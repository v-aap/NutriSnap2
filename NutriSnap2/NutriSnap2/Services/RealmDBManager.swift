import Foundation
import RealmSwift

class RealmDBManager {
    static let shared = RealmDBManager()
    private var app: App
    private var user: User?

    private init() {
        self.app = App(id: "your-realm-app-id") // 🔹 Replace with your MongoDB Realm App ID
        self.user = app.currentUser
    }

    // MARK: - Register User
    func registerUser(firstName: String, lastName: String, email: String, password: String, calorieGoal: Int?) async -> Bool {
        do {
            try await app.emailPasswordAuth.registerUser(email: email, password: password)
            print("✅ User registration successful!")

            // Auto login after registration
            return await loginUser(email: email, password: password)
        } catch {
            print("❌ Registration failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - User Login
    func loginUser(email: String, password: String) async -> Bool {
        do {
            let credentials = Credentials.emailPassword(email: email, password: password)
            let user = try await app.login(credentials: credentials)
            self.user = user
            print("✅ Login successful for user: \(user.id)")
            return true
        } catch {
            print("❌ Login failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Get Logged-in User
    func getCurrentUser() -> User? {
        return app.currentUser
    }

    // MARK: - Logout User
    func logoutUser() async {
        guard let user = app.currentUser else { return }
        do {
            try await user.logOut()
            print("✅ User logged out successfully")
        } catch {
            print("❌ Logout failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch User Profile Data
    func fetchUserProfile() async -> UserModel? {
        guard let user = app.currentUser else {
            print("❌ No user logged in")
            return nil
        }
        
        let realm = try! await Realm(configuration: user.flexibleSyncConfiguration())
        let userData = realm.objects(UserModel.self).first
        
        return userData
    }

    // MARK: - Sync User Data
    func syncUserData(userModel: UserModel) async {
        guard let user = app.currentUser else { return }

        let realm = try! await Realm(configuration: user.flexibleSyncConfiguration())
        try! realm.write {
            realm.add(userModel, update: .modified)
        }
        print("✅ User data synced successfully")
    }
}
