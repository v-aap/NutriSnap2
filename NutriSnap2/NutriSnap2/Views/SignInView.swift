import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var showErrorAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: {
                    viewModel.signIn()
                    if !viewModel.isAuthenticated {
                        showErrorAlert = true // Show error if login fails
                    }
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()

                // Show error alert if login fails
                .alert(isPresented: $showErrorAlert) {
                    Alert(
                        title: Text("Login Failed"),
                        message: Text("Invalid email or password. Please try again."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadUserSession() // Load stored user session if available
        }
        .fullScreenCover(isPresented: $viewModel.isAuthenticated) { // Navigates when authenticated
            RootContainerView()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .previewDevice("iPhone 14 Plus")
    }
}
