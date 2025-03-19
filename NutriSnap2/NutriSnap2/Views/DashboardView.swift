import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    @State private var selectedDate: Date = Date()
    @State private var user: UserModel? = nil  // Stores fetched user data

    // Example daily goal and calories consumed (replace with dynamic data as needed)
    let dailyGoal: Int = 1200
    let breakfastCalories: Int = 50
    let lunchCalories: Int = 300
    let dinnerCalories: Int = 250
    let snackCalories: Int = 100

    // Computed properties
    var totalConsumed: Int {
        breakfastCalories + lunchCalories + dinnerCalories + snackCalories
    }

    var remaining: Int {
        dailyGoal - totalConsumed
    }

    var progress: Double {
        let ratio = Double(totalConsumed) / Double(dailyGoal)
        return min(ratio, 1.0)
    }

    var ringColor: Color {
        remaining >= 0 ? .green : .red
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Welcome Message
            HStack {
                Text("Welcome, \(user?.firstName ?? "User")") // ✅ Handles nil case properly
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .onAppear {
                fetchUserData()
            }

            // Date Navigation
            HStack {
                Button(action: {
                    if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
                        selectedDate = newDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundColor(.blue)
                }

                Spacer()

                Text(formattedDate)
                    .font(.headline)

                Spacer()

                Button(action: {
                    if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
                        selectedDate = newDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            // Daily Progress Ring
            ZStack {
                DailyProgressRing(progress: progress, ringColor: ringColor)
                VStack {
                    if remaining >= 0 {
                        Text("\(remaining)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Remaining")
                            .font(.subheadline)
                    } else {
                        Text("\(abs(remaining))")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Over")
                            .font(.subheadline)
                    }
                }
            }

            // Macros Section
            HStack(spacing: 40) {
                VStack {
                    Text("Carbs")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("50/200 g")
                        .font(.headline)
                }

                VStack {
                    Text("Protein")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("60/150 g")
                        .font(.headline)
                }

                VStack {
                    Text("Fats")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("30/70 g")
                        .font(.headline)
                }
            }
            .padding(.vertical)

            // Sample Meals List
            VStack(spacing: 16) {
                MealRowView(iconName: "sunrise.fill", mealName: "Breakfast", currentCalories: breakfastCalories, totalCalories: 500)
                MealRowView(iconName: "sun.max.fill", mealName: "Lunch", currentCalories: lunchCalories, totalCalories: 600)
                MealRowView(iconName: "moon.stars.fill", mealName: "Dinner", currentCalories: dinnerCalories, totalCalories: 700)
                MealRowView(iconName: "takeoutbag.and.cup.and.straw.fill", mealName: "Snacks", currentCalories: snackCalories, totalCalories: 300)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Fetch User's First Name from Firestore
    private func fetchUserData() {
        FirestoreService.shared.fetchUserData { fetchedUser in
            DispatchQueue.main.async {
                self.user = fetchedUser
                print("✅ User Data Fetched: \(fetchedUser?.firstName ?? "Unknown")")
            }
        }
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .previewDevice("iPhone 14 Plus")
    }
}
