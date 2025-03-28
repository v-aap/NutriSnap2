import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    @State private var selectedDate: Date = Date()
    @State private var user: UserModel? = nil
    @State private var totalCalories: Int = 0
    @State private var calorieGoal: Int = 0
    @State private var totalCarbs: Int = 0
    @State private var totalProtein: Int = 0
    @State private var totalFats: Int = 0
    @State private var mealCalories: [MealType: Int] = [:]
    @State private var showGoalSetupAlert = false
    @State private var animatedProgress: Double = 0.0
    @State private var navigateToEditGoals = false

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        NavigationView {
            if let user = user {
                VStack(spacing: 16) {
                    // Welcome Message
                    HStack {
                        Text("Welcome, \(user.firstName)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Date Navigation
                    HStack {
                        Button(action: {
                            if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
                                selectedDate = newDate
                                analyzeNutrition()
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
                                analyzeNutrition()
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
                        DailyProgressRing(progress: animatedProgress, ringColor: totalCalories <= calorieGoal ? .green : .red)
                        VStack {
                            if totalCalories <= calorieGoal {
                                Text("\(calorieGoal - totalCalories)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Remaining")
                                    .font(.subheadline)
                            } else {
                                Text("\(totalCalories - calorieGoal)")
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
                            Text("\(totalCarbs) g")
                                .font(.headline)
                        }
                        VStack {
                            Text("Protein")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(totalProtein) g")
                                .font(.headline)
                        }
                        VStack {
                            Text("Fats")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(totalFats) g")
                                .font(.headline)
                        }
                    }
                    .padding(.vertical)

                    // Meal Progress Views
                    VStack(spacing: 16) {
                        MealRowView(iconName: "sunrise.fill", mealName: "Breakfast", currentCalories: mealCalories[.breakfast] ?? 0, totalCalories: NutritionAnalysisService.shared.calculateMealGoal(for: .breakfast, user: user))
                        MealRowView(iconName: "sun.max.fill", mealName: "Lunch", currentCalories: mealCalories[.lunch] ?? 0, totalCalories: NutritionAnalysisService.shared.calculateMealGoal(for: .lunch, user: user))
                        MealRowView(iconName: "moon.stars.fill", mealName: "Dinner", currentCalories: mealCalories[.dinner] ?? 0, totalCalories: NutritionAnalysisService.shared.calculateMealGoal(for: .dinner, user: user))
                        MealRowView(iconName: "takeoutbag.and.cup.and.straw.fill", mealName: "Snacks", currentCalories: mealCalories[.snack] ?? 0, totalCalories: NutritionAnalysisService.shared.calculateMealGoal(for: .snack, user: user))
                    }
                    .padding(.horizontal)

                    Spacer()

                    NavigationLink(destination: EditCalorieGoalView(user: Binding(get: { user }, set: { self.user = $0 })), isActive: $navigateToEditGoals) {
                        EmptyView()
                    }
                }
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                .alert(isPresented: $showGoalSetupAlert) {
                    Alert(
                        title: Text("Nutrition Goals Not Set"),
                        message: Text("Please set your nutrition and meal distribution goals in your profile to use the dashboard."),
                        primaryButton: .default(Text("Set Now")) {
                            navigateToEditGoals = true
                        },
                        secondaryButton: .cancel(Text("Later"))
                    )
                }
                .onAppear {
                    fetchUserData()
                    analyzeNutrition()
                    
                    if user.hasSetGoal {
                        showGoalSetupAlert = false
                    } else {
                        showGoalSetupAlert = true
                    }
                    withAnimation(.easeInOut(duration: 1.0)) {
                        animatedProgress = Double(totalCalories) / Double(calorieGoal == 0 ? 1 : calorieGoal)
                    }
                }
            } else {
                ProgressView("Loading user data...")
                    .onAppear {
                        fetchUserData()
                        analyzeNutrition()
                    }
            }
        }
    }

    // MARK: - Fetch User Data
    private func fetchUserData() {
        FirestoreService.shared.fetchUserData { fetchedUser in
            DispatchQueue.main.async {
                self.user = fetchedUser
                self.calorieGoal = fetchedUser?.calorieGoal ?? 2000
                self.showGoalSetupAlert = !(fetchedUser?.hasSetGoal ?? false)
            }
        }
    }

    // MARK: - Analyze Nutrition
    private func analyzeNutrition() {
        NutritionAnalysisService.shared.analyzeNutrition(for: selectedDate) { calories, goal, carbs, protein, fats, mealsByType in
            DispatchQueue.main.async {
                self.totalCalories = calories
                self.calorieGoal = goal
                self.totalCarbs = carbs
                self.totalProtein = protein
                self.totalFats = fats
                self.mealCalories = mealsByType

                withAnimation(.easeInOut(duration: 1.0)) {
                    self.animatedProgress = Double(calories) / Double(goal == 0 ? 1 : goal)
                }
            }
        }
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
