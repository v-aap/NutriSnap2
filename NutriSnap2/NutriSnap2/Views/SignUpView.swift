import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @State private var navigateToSignIn = false
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 40)

                    // First Name Input
                    InputField(title: "First Name *", text: $viewModel.firstName,
                               errorMessage: viewModel.firstName.isEmpty ? "⚠️ First Name is required." : nil)

                    // Last Name Input
                    InputField(title: "Last Name *", text: $viewModel.lastName,
                               errorMessage: viewModel.lastName.isEmpty ? "⚠️ Last Name is required." : nil)

                    // Email Input
                    InputField(title: "Email *", text: $viewModel.email, errorMessage: viewModel.emailError)

                    // Password Input
                    SecureInputField(title: "Password *", text: $viewModel.password, errorMessage: viewModel.passwordError)

                    // Confirm Password Input
                    SecureInputField(title: "Confirm Password *", text: $viewModel.confirmPassword, errorMessage: viewModel.confirmPasswordError)

                    // Daily Calorie Goal Input (Optional)
                    TextField("Daily Calorie Goal (Optional)", text: Binding(
                        get: { viewModel.dailyCalorieGoal.map { String($0) } ?? "" },
                        set: { viewModel.dailyCalorieGoal = Int($0) }
                    ))
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                    // Sign-Up Button
                    Button(action: {
                        print("Sign Up Button Pressed")
                        Task {
                            await viewModel.signUp()
                            showAlert = true
                        }
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.isFormValid ? Color.green : Color.gray)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .disabled(!viewModel.isFormValid)

                    // Already have an account? Sign In
                    Button(action: {
                        DispatchQueue.main.async {
                            navigateToSignIn = true
                        }
                    }) {
                        Text("Already have an account? Sign In")
                            .foregroundColor(.blue)
                            .underline()
                            .padding(.top, 10)
                    }

                    Spacer()
                }
                .padding(.bottom, 20)
                .onTapGesture { hideKeyboard() }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationDestination(isPresented: $navigateToSignIn) {
                SignInView()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(viewModel.isRegistered ? "Success" : "Error"),
                    message: Text(viewModel.isRegistered ? "Account created successfully!" : viewModel.registrationError ?? "Something went wrong."),
                    dismissButton: .default(Text("OK")) {
                        if viewModel.isRegistered { navigateToSignIn = true }
                    }
                )
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
