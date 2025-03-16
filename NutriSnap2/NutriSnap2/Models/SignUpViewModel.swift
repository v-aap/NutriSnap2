import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var dailyCalorieGoal: String = "2000"
    
    @Published var isRegistered = false 

    // MARK: - Validate Required Fields
    var isFormValid: Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               !email.isEmpty &&
               !password.isEmpty &&
               !confirmPassword.isEmpty &&
               password == confirmPassword
    }

    // MARK: - Sign Up Function
    func signUp() {
        guard isFormValid else {
            isRegistered = false 
            return
        }

        let user = UserModel(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            calorieGoal: Int(dailyCalorieGoal)
        )

            let success = await MongoDBManager.shared.registerUser(user: user)
            DispatchQueue.main.async {
                self.isRegistered = success 
            }
        }
    }
}
