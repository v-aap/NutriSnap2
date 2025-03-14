import SwiftUI

struct ProfileView: View {
    // MARK: - State Variables
    @State private var firstName: String = "John"
    @State private var lastName: String = "Doe"
    @State private var email: String = "johndoe@email.com"
    @State private var nutritionGoal = NutritionGoal.defaultGoal
    @State private var notificationsEnabled: Bool = true
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
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
                
                Text("\(firstName) \(lastName)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.top, 8)
            }
            
            // MARK: - Settings List
            List {
                // MARK: - Personal Information
                NavigationLink(destination: EditPersonalInfoView(firstName: $firstName, lastName: $lastName, email: $email)) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                        Text("Personal Information")
                    }
                }
                
                // MARK: - Calorie Goal (Clickable)
                NavigationLink(destination: EditCalorieGoalView(nutritionGoal: $nutritionGoal)) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Calorie Goal: \(nutritionGoal.calorieGoal) kcal/day")
                    }
                }
                
                // MARK: - Notifications Toggle
                Toggle(isOn: $notificationsEnabled) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.green)
                        Text("Notifications")
                    }
                }
                
                // MARK: - Logout Button
                Section {
                    Button(action: {
                        // Navigate back to SignInView
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.red)
                            Text("Log Out")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .frame(height: 350)
            
            Spacer()
        }
        .navigationTitle("Profile")
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
