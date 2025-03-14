import SwiftUI

struct DashboardView: View {
    @State private var selectedDate: Date = Date()
    
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
            .padding(.top, 16)
            
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
            .padding(.top, 8)
            
            // Macros Section (Placeholder data)
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
            
            // Sample Meals List (Reusable MealRowView instances)
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
}

// MARK: - DailyProgressRing
struct DailyProgressRing: View {
    let progress: Double  // Expected range: 0.0 to 1.0
    let ringColor: Color
    var size: CGFloat = 120
    var lineWidth: CGFloat = 10
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
                .frame(width: size, height: size)
            // Foreground progress ring
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
        }
    }
}

// MARK: - MealRowView (Reusable for Meal Rows)
struct MealRowView: View {
    let iconName: String
    let mealName: String
    let currentCalories: Int
    let totalCalories: Int
    
    // Calculate progress for the meal's consumption
    var progress: Double {
        guard totalCalories > 0 else { return 0 }
        return min(Double(currentCalories) / Double(totalCalories), 1.0)
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.green)
            Text(mealName)
                .font(.headline)
            Spacer()
            Text("\(currentCalories)/\(totalCalories) Cal")
                .font(.subheadline)
            ProgressRing(progress: progress)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ProgressRing (Reusable for Meal Rows)
struct ProgressRing: View {
    let progress: Double  // Expected range: 0.0 to 1.0
    var lineWidth: CGFloat = 4
    var size: CGFloat = 24
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
                .frame(width: size, height: size)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(Color.green, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
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
