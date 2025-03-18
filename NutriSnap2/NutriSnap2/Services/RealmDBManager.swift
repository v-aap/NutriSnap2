import Foundation
import RealmSwift

class RealmDBManager {
    static let shared = RealmDBManager()
    private let app = App(id: "nutrisnap-uaftlyk")
    private var currentUser: UserModel?

    private init() {}

    // MARK: - Register User
    func registerUser(firstName: String, lastName: String, email: String, password: String, calorieGoal: Int?) async -> Bool {
        do {
            try await app.emailPasswordAuth.registerUser(email: email, password: password)
            print("✅ User registration successful!")

            let loginSuccess = await loginUser(email: email, password: password)
            if loginSuccess {
                await callUserProfileTrigger(email: email)
                await saveUserToDatabase(firstName: firstName, lastName: lastName, email: email, calorieGoal: calorieGoal)
            }
            return loginSuccess
        } catch {
            print("❌ Registration failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Login User
    func loginUser(email: String, password: String) async -> Bool {
        do {
            let credentials = Credentials.emailPassword(email: email, password: password)
            let user = try await app.login(credentials: credentials)
            print("✅ Login successful for: \(user.id)")

            await setUser(user, withEmail: email)
            return true
        } catch {
            print("❌ Login failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Save User to Database
    func saveUserToDatabase(firstName: String, lastName: String, email: String, calorieGoal: Int?) async {
        guard let user = app.currentUser else {
            print("❌ No authenticated user found")
            return
        }
        do {
            let realm = try await Realm(configuration: user.flexibleSyncConfiguration())
            try await realm.asyncWrite {
                let newUser = UserModel()
                newUser._id = ObjectId.generate()
                newUser.firstName = firstName
                newUser.lastName = lastName
                newUser.email = email
                newUser.dailyCalorieGoal = calorieGoal
                realm.add(newUser)
                print("✅ User successfully saved to MongoDB")
            }
        } catch {
            print("❌ Error saving user: \(error.localizedDescription)")
        }
    }

    // MARK: - Execute Trigger Function
    func callUserProfileTrigger(email: String) async {
        do {
            guard let user = app.currentUser else {
                print("❌ No authenticated user to call trigger")
                return
            }
            let functions = user.functions
            let userData: [String: Any] = ["email": email]
            let args: [Any] = [userData]
            let result = try await functions.call("afterUserCreation", args)
            print("✅ Trigger executed with result: \(String(describing: result))")
        } catch {
            print("❌ Trigger execution failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch User Profile
    func fetchUserProfile() async -> UserModel? {
        guard let user = app.currentUser else {
            print("❌ No authenticated user found")
            return nil
        }
        do {
            let realm = try await Realm(configuration: user.flexibleSyncConfiguration())
            let userEmail = user.profile.email ?? ""
            if userEmail.isEmpty {
                print("❌ User email is missing in profile")
                return nil
            }
            if let userData = realm.objects(UserModel.self).filter("email == %@", userEmail).first {
                DispatchQueue.main.async {
                    self.currentUser = userData
                }
                print("✅ User profile retrieved: \(userData.firstName) \(userData.lastName)")
                return userData
            } else {
                print("❌ User profile not found in the database")
                return nil
            }
        } catch {
            print("❌ Error fetching user profile: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Store User Session
    func setUser(_ user: User, withEmail email: String? = nil) async {
        do {
            let realm = try await Realm(configuration: user.flexibleSyncConfiguration())
            let userEmail = email ?? user.profile.email
            guard let validEmail = userEmail, !validEmail.isEmpty else {
                print("❌ User email is missing, cannot set session")
                return
            }
            if let userData = realm.objects(UserModel.self).filter("email == %@", validEmail).first {
                DispatchQueue.main.async {
                    self.currentUser = userData
                }
                print("✅ User session set for: \(userData.firstName) \(userData.lastName)")
            } else {
                print("❌ User session could not be set, user not found in DB")
            }
        } catch {
            print("❌ Error setting user session: \(error.localizedDescription)")
        }
    }

    // MARK: - Clear User Session
    func clearUserSession() async {
        DispatchQueue.main.async {
            self.currentUser = nil
            print("✅ User session cleared")
        }
    }

    // MARK: - Logout User
    func logoutUser() async {
        if let user = app.currentUser {
            do {
                try await user.logOut()
                await clearUserSession()
                print("✅ User logged out successfully")
            } catch {
                print("❌ Logout failed: \(error.localizedDescription)")
            }
        }
    }
}
