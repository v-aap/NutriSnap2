import SwiftUI
import RealmSwift
import Combine

class SignUpViewModel: ObservableObject {
    @Published var firstName = "" { didSet { validateForm() } }
    @Published var lastName = "" { didSet { validateForm() } }
    @Published var email = "" { didSet { validateEmail() } }
    @Published var password = "" { didSet { validatePassword() } }
    @Published var confirmPassword = "" { didSet { validatePassword() } }
    @Published var dailyCalorieGoal: Int? = nil

    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    @Published var isRegistered = false
    @Published var registrationError: String?
    @Published var currentUser: UserModel?

    let app = App(id: "nutrisnap-uaftlyk")

    var isFormValid: Bool {
        return emailError == nil &&
               passwordError == nil &&
               confirmPasswordError == nil &&
               !firstName.isEmpty &&
               !lastName.isEmpty
    }

    private func validateEmail() {
        let isValid = NSPredicate(format: "SELF MATCHES %@", "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$").evaluate(with: email)
        emailError = isValid ? nil : "⚠️ Enter a valid email address."
    }

    private func validatePassword() {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let isStrong = NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
        passwordError = isStrong ? nil : "⚠️ Password must have at least 8 characters, one uppercase, one number, and one special character."

        let isMatching = password == confirmPassword && !password.isEmpty
        confirmPasswordError = isMatching ? nil : "⚠️ Passwords do not match."
    }

    private func validateForm() {
        validateEmail()
        validatePassword()
    }

    // MARK: - Sign Up Function
    func signUp() async {
        guard isFormValid else {
            DispatchQueue.main.async {
                self.registrationError = "Please fix all errors before proceeding."
            }
            return
        }

        // Use the centralized registration method from RealmDBManager.
        let success = await RealmDBManager.shared.registerUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            calorieGoal: dailyCalorieGoal
        )
        
        if success {
            // Optionally, fetch user profile data to update UI.
            await fetchUserProfile()
        }
        
        DispatchQueue.main.async {
            self.isRegistered = success
        }
    }

    // MARK: - Fetch User Profile from Realm
    func fetchUserProfile() async {
        if let userData = await RealmDBManager.shared.fetchUserProfile() {
            DispatchQueue.main.async {
                self.firstName = userData.firstName
                self.lastName = userData.lastName
                self.currentUser = userData
                print("✅ Fetched User: \(self.firstName) \(self.lastName)")
            }
        } else {
            print("❌ No user data found in database")
        }
    }
}
