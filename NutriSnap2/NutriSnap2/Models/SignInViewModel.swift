import SwiftUI

class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var errorMessage: String?

    // MARK: - Sign In Function
    func signIn(completion: @escaping (Bool) -> Void) {
        AuthService.shared.signIn(email: email, password: password) { success, error in
            DispatchQueue.main.async {
                if success {
                    AuthService.shared.checkIfUserHasGoal { userHasGoal in
                        completion(userHasGoal)
                    }
                } else {
                    self.errorMessage = error
                    completion(false)
                }
            }
        }
    }
}
