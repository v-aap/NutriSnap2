import SwiftUI

struct MealCardView: View {
    let meal: MealEntry
    let showDate: Bool
    let showType: Bool

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "fork.knife")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 5) {
                Text(meal.foodName)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 20) {
                    VStack {
                        Text("🔥")
                        Text("\(meal.calories) kcal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    VStack {
                        Text("🥩")
                        Text("\(meal.protein)g")
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

                if showType || showDate {
                    HStack {
                        if showType {
                            Text("🍽 \(meal.mealType)").font(.footnote).foregroundColor(.gray)
                        }
                        if showDate {
                            Text("📅 \(meal.date, style: .date)").font(.footnote).foregroundColor(.gray)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
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
                userID: "testUserID", 
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
