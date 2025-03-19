import SwiftUI

struct ProfileView: View {
    @State private var user: UserModel? = nil
    @State private var isLoggedOut = false
    @State private var notificationsEnabled: Bool = true

    var body: some View {
        VStack {
            if let user = user {
                // Profile Header
                VStack {
                    Image("profile_placeholder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                        // Reduced top padding from 40 to 20
                        .padding(.top, 20)

                    Text("\(user.firstName) \(user.lastName)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 8)
                }

                // Settings List
                List {
                    // Personal Info
                    NavigationLink(destination: EditPersonalInfoView(
                        firstName: .constant(user.firstName),
                        lastName: .constant(user.lastName),
                        email: .constant(user.email)
                    )) {
                        SettingsRow(icon: "person.fill", color: .blue, title: "Personal Information")
                    }

                    // Calorie Goal
                    NavigationLink(destination: EditCalorieGoalView(nutritionGoal: .constant(NutritionGoal.defaultGoal))) {
                        SettingsRow(icon: "flame.fill", color: .orange, title: "Calorie Goal: \(user.calorieGoal) kcal/day")
                    }

                    // Notifications
                    Toggle(isOn: $notificationsEnabled) {
                        SettingsRow(icon: "bell.fill", color: .green, title: "Notifications")
                    }

                    // Logout
                    Section {
                        Button(action: logout) {
                            SettingsRow(icon: "arrow.right.circle.fill", color: .red, title: "Log Out", isDestructive: true)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

            } else {
                // Loading State
                VStack {
                    ProgressView()
                    Text("Loading profile...")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .onAppear(perform: fetchUserData)
            }

            Spacer()
        }
        .onAppear(perform: fetchUserData)
        .fullScreenCover(isPresented: $isLoggedOut) {
            SignInView()
        }
    }

    // Fetch User Data
    private func fetchUserData() {
        FirestoreService.shared.fetchUserData { fetchedUser in
            DispatchQueue.main.async {
                self.user = fetchedUser
            }
        }
    }

    // Logout
    private func logout() {
        AuthService.shared.signOut { success, error in
            DispatchQueue.main.async {
                if success {
                    isLoggedOut = true
                } else {
                    print("Logout failed: \(error ?? "Unknown error")")
                }
            }
        }
    }
}

// MARK: - SettingsRow
struct SettingsRow: View {
    let icon: String
    let color: Color
    let title: String
    var isDestructive: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .foregroundColor(isDestructive ? .red : .primary)
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
