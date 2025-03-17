import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @State private var navigateToSignIn = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                // Required Fields with Validation Indication
                TextField("First Name *", text: $viewModel.firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Last Name *", text: $viewModel.lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("name@example.com *", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                SecureField("Password *", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                SecureField("Confirm Password *", text: $viewModel.confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Daily Calorie Goal (Optional)", text: Binding(
                    get: { viewModel.dailyCalorieGoal.map { String($0) } ?? "" },
                    set: { viewModel.dailyCalorieGoal = Int($0) }
                ))
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

                // Disable button if form is invalid
                Button(action: {
                    Task {
                        await viewModel.signUp()
                    }
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isFormValid ? Color.green : Color.gray) // Disabled if invalid
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .disabled(!viewModel.isFormValid) // Disable if fields are empty

                Spacer()

                // NavigationLink to SignInView
                NavigationLink(destination: SignInView(), isActive: $navigateToSignIn) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)

            // Alert for Both Success & Error
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.isRegistered },
                set: { newValue in viewModel.isRegistered = newValue }
            )) {
                Alert(
                    title: Text(viewModel.isRegistered ? "Success" : "Error"),
                    message: Text(viewModel.isRegistered ? "Account created successfully!" : "There was an error creating your account. Please try again."),
                    dismissButton: .default(Text("OK")) {
                        if viewModel.isRegistered {
                            navigateToSignIn = true
                        }
                    }
                )
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .previewDevice("iPhone 14 Plus")
    }
}
