import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var navigateToGoalSetup = false
    @State private var navigateToDashboard = false

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
                    viewModel.signIn { userHasGoal in
                        if userHasGoal {
                            navigateToDashboard = true
                        } else {
                            navigateToGoalSetup = true
                        }
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

                NavigationLink(destination: DashboardView(), isActive: $navigateToDashboard) {
                    EmptyView()
                }
                NavigationLink(destination: EditCalorieGoalView(nutritionGoal: .constant(NutritionGoal.defaultGoal)), isActive: $navigateToGoalSetup) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
    }
}
