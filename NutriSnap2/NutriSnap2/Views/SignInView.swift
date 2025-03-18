import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var navigateToGoalSetup = false
    @State private var navigateToRootContainer = false
    @State private var navigateToSignUp = false
    @State private var showPasswordResetAlert = false
    @State private var passwordResetMessage: String = ""
    @State private var showSignInErrorAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                // MARK: - Email Input
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(.horizontal)

                // MARK: - Password Input
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // MARK: - Sign In Button
                Button(action: {
                    viewModel.signIn { userHasGoal in
                        if userHasGoal {
                            navigateToRootContainer = true
                        } else {
                            navigateToGoalSetup = true
                        }
                        if viewModel.errorMessage != nil {
                            showSignInErrorAlert = true
                        }
                    }
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isFormValid ? Color.green : Color.gray)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .disabled(!viewModel.isFormValid)

                // Forgot Password Button
                Button(action: {
                    AuthService.shared.resetPassword(email: viewModel.email) { success, message in
                        passwordResetMessage = message ?? "Unknown error"
                        showPasswordResetAlert = true
                    }
                }) {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                        .font(.footnote)
                        .underline()
                }
                .padding(.top, 5)

                // Sign-Up Navigation Button
                Button(action: {
                    navigateToSignUp = true
                }) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                        .font(.footnote)
                        .underline()
                }
                .padding(.top, 5)

                Spacer()

                // MARK: - Navigation Destinations
                .navigationDestination(isPresented: $navigateToRootContainer) {
                    RootContainerView()
                }
                .navigationDestination(isPresented: $navigateToGoalSetup) {
                    EditCalorieGoalView(nutritionGoal: .constant(NutritionGoal.defaultGoal))
                }
                .navigationDestination(isPresented: $navigateToSignUp) {
                    SignUpView()
                }
            }
            .navigationBarHidden(true)
            .alert("Password Reset", isPresented: $showPasswordResetAlert) {
                Button("OK") {}
            } message: {
                Text(passwordResetMessage)
            }
            .alert("Sign In Failed", isPresented: $showSignInErrorAlert) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
}
