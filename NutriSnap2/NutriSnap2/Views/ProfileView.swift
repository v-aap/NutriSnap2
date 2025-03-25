import SwiftUI

struct ProfileView: View {
    // MARK: - State Variables
    @State private var user: UserModel? = nil
    @State private var isLoggedOut = false
    @State private var notificationsEnabled: Bool = true

    var body: some View {
        NavigationView {
            VStack {
                if let user = user {
                    // MARK: - Profile Picture & Name
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
                            .padding(.top, 40)

                        Text("\(user.firstName) \(user.lastName)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                    }

                    // MARK: - Settings List
                    List {
                        // MARK: - Personal Information
                        NavigationLink(destination: EditPersonalInfoView(
                            firstName: .constant(user.firstName),
                            lastName: .constant(user.lastName),
                            email: .constant(user.email))) {
                            SettingsRow(icon: "person.fill", color: .blue, title: "Personal Information")
                        }

                        // MARK: - Calorie Goal (Clickable)
                        NavigationLink(destination: EditCalorieGoalView(user: Binding(get: {
                            self.user ?? UserModel(
                                id: UUID().uuidString,
                                firstName: "",
                                lastName: "",
                                email: ""
                            )
                        }, set: { newUser in
                            self.user = newUser
                        }))) {
                            SettingsRow(icon: "flame.fill", color: .orange, title: "Calorie Goal: \(user.calorieGoal) kcal/day")
                        }


                        // MARK: - Notifications Toggle
                        Toggle(isOn: $notificationsEnabled) {
                            SettingsRow(icon: "bell.fill", color: .green, title: "Notifications")
                        }

                        // MARK: - Logout Button
                        Section {
                            Button(action: logout) {
                                SettingsRow(icon: "arrow.right.circle.fill", color: .red, title: "Log Out", isDestructive: true)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    // MARK: - Loading State
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
            .navigationTitle("Profile")
            .onAppear(perform: fetchUserData)
            .fullScreenCover(isPresented: $isLoggedOut) {
                SignInView()
            }
        }
    }

    // MARK: - Fetch User Data
    private func fetchUserData() {
        FirestoreService.shared.fetchUserData { fetchedUser in
            DispatchQueue.main.async {
                self.user = fetchedUser
            }
        }
    }

    // MARK: - Logout Function
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

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
