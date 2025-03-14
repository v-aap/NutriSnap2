import SwiftUI

struct MealCardView: View {
    let meal: MealEntry
    let showDate: Bool
    let showType: Bool

    var body: some View {
        HStack(spacing: 15) {
            // Food Icon Placeholder (Customize as needed)
            Image(systemName: "fork.knife") // Replace with an actual image if needed
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 5) {
                // Meal Name
                Text(meal.foodName)
                    .font(.headline)
                    .foregroundColor(.primary)

                // Macronutrients & Calories
                HStack(spacing: 20) {
                    VStack {
                        Text("🔥") // Emoji on top
                        Text("\(meal.calories) kcal") // Value below
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("🥩") // Emoji
                        Text("\(meal.protein)g") // Value
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack {
                        Text("🍞")
                        Text("\(meal.carbs)g")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack {
                        Text("🧈")
                        Text("\(meal.fats)g")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // Meal Type and Date (if enabled)
                if showType || showDate {
                    HStack {
                        if showType {
                            HStack {
                                Text("🍽 \(meal.mealType)")
                            }
                            .font(.footnote)
                            .foregroundColor(.gray)
                        }
                        if showDate {
                            HStack {
                                Text("📅 \(meal.date, style: .date)")
                            }
                            .font(.footnote)
                            .foregroundColor(.gray)
                        }
                    }
                }
            }

            Spacer() // Pushes everything left to ensure full-width layout
        }
        .padding()
        .frame(maxWidth: .infinity) // Expands card to full width
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
struct MealCardView_Previews: PreviewProvider {
    static var previews: some View {
        MealCardView(
            meal: MealEntry(
                date: Date(),
                foodName: "Example Meal",
                calories: 400,
                carbs: 50,
                protein: 30,
                fats: 10,
                isManualEntry: true,
                mealType: "Breakfast"
            ),
            showDate: true,
            showType: true
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
