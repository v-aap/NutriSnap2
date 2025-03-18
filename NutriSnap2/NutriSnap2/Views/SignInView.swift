import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var showErrorAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Title
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                // Email Input (Using CustomInputFields)
                InputField(title: "Email", text: $viewModel.email,
                           errorMessage: viewModel.emailError)

                // Password Input (Using CustomInputFields)
                SecureInputField(title: "Password", text: $viewModel.password,
                                 errorMessage: viewModel.passwordError)

                // Sign In Button
                Button(action: {
                    Task {
                        await viewModel.signIn()
                        if !viewModel.isAuthenticated {
                            showErrorAlert = true
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

                Spacer()

                // Error Alert
                .alert(isPresented: $showErrorAlert) {
                    Alert(
                        title: Text("Login Failed"),
                        message: Text("Invalid email or password. Please try again."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .padding(.horizontal)
            .onTapGesture { hideKeyboard() }
            .navigationBarHidden(true)
        }
    }

    // Hide Keyboard Function
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .previewDevice("iPhone 14 Plus")
    }
}
