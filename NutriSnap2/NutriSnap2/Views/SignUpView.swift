import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @State private var navigateToRootContainer = false
    @State private var showSuccessAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                // MARK: - First Name Input
                TextField("First Name *", text: $viewModel.firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.words)
                    .padding(.horizontal)

                // MARK: - Last Name Input
                TextField("Last Name *", text: $viewModel.lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.words)
                    .padding(.horizontal)

                // MARK: - Email Input
                TextField("name@example.com *", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(.horizontal)

                // MARK: - Password Input
                SecureField("Password *", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // MARK: - Confirm Password Input
                SecureField("Confirm Password *", text: $viewModel.confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // MARK: - Sign Up Button
                Button(action: {
                    viewModel.signUp { success in
                        if success {
                            showSuccessAlert = true
                        }
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

                Spacer()
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Alert(
                    title: Text("Sign Up Failed"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert("Account Created", isPresented: $showSuccessAlert) {
                Button("OK") {
                    navigateToRootContainer = true
                }
            } message: {
                Text("Your account has been successfully created. Tap OK to proceed to login.")
            }
            .navigationDestination(isPresented: $navigateToRootContainer) {
                RootContainerView()
            }
            .navigationBarHidden(true)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .previewDevice("iPhone 14 Plus")
    }
}
