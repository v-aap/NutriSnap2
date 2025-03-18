import SwiftUI
import RealmSwift

class SignInViewModel: ObservableObject {
    @Published var email = "" {
        didSet { validateEmail() }
    }
    @Published var password = "" {
        didSet { validatePassword() }
    }
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var isAuthenticated = false
    @Published var currentUser: UserModel?

    // MARK: - Error Handling
    @Published var emailError: String?
    @Published var passwordError: String?

    private let app = App(id: "nutrisnap-uaftlyk")

    // MARK: - Computed Property: Form Validation
    var isFormValid: Bool {
        return !email.isEmpty && emailError == nil && !password.isEmpty
    }

    // MARK: - Validate Email
    private func validateEmail() {
        DispatchQueue.main.async {
            let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
            let isValid = NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self.email)
            self.emailError = isValid ? nil : "⚠️ Enter a valid email address."
        }
    }

    // MARK: - Validate Password
    private func validatePassword() {
        DispatchQueue.main.async {
            self.passwordError = self.password.isEmpty ? "⚠️ Password cannot be empty." : nil
        }
    }

    // MARK: - Sign In Function
    func signIn() async {
        guard isFormValid else {
            DispatchQueue.main.async {
                self.emailError = self.email.isEmpty ? "⚠️ Email is required." : self.emailError
                self.passwordError = self.password.isEmpty ? "⚠️ Password is required." : self.passwordError
            }
            print("❌ Invalid form data")
            return
        }

        do {
            let credentials = Credentials.emailPassword(email: email, password: password)
            let user = try await app.login(credentials: credentials)
            print("✅ Login successful for: \(user.id)")

            DispatchQueue.main.async {
                self.isAuthenticated = true
            }

            // Store user session using the provided email.
            await RealmDBManager.shared.setUser(user, withEmail: email)

            // Fetch user profile data after login.
            await fetchUserProfile()
        } catch {
            DispatchQueue.main.async {
                self.emailError = "⚠️ Invalid email or password."
                self.passwordError = "⚠️ Invalid email or password."
            }
            print("❌ Login failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch User Profile via API
    func fetchUserProfile() async {
        // Alternatively, if you prefer fetching via an API endpoint, use the code below.
        guard let apiUrl = URL(string: "https://data.mongodb-api.com/app/nutrisnap-uaftlyk/endpoint/getUserByEmail") else {
            print("❌ Invalid API URL")
            return
        }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["email": email])

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Failed to fetch user profile.")
                return
            }

            let userData = try JSONDecoder().decode(UserModel.self, from: data)
            DispatchQueue.main.async {
                self.firstName = userData.firstName
                self.lastName = userData.lastName
                self.currentUser = userData
                print("✅ User profile loaded: \(self.firstName) \(self.lastName)")
            }
        } catch {
            print("❌ Error fetching user profile: \(error)")
        }
    }

    // MARK: - Logout Function
    func logout() async {
        if let user = app.currentUser {
            do {
                try await user.logOut()
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    self.currentUser = nil
                    self.email = ""
                    self.password = ""
                }
                print("✅ User logged out successfully")
            } catch {
                print("❌ Logout failed: \(error.localizedDescription)")
            }
        }
    }
}
