import SwiftUI
import Combine

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    func forgotPassword() {
        print("Forgot password for \(email)")
    }
    
    func signIn() {
        // Placeholder: perform sign in logic.
        print("Signing in with email: \(email)")
    }
}
