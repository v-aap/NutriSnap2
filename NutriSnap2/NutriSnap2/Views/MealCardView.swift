import SwiftUI
import FirebaseAuth

struct MealCardView: View {
    let meal: MealEntry
    let showDate: Bool
    let showType: Bool
    let favourites: [FavoriteMeal]

    var isFavourite: Bool {
        favourites.contains(where: { $0.isSame(as: meal) })
    }

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
                HStack {
                    Text(meal.foodName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if isFavourite {
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }

                Text("\(meal.calories) kcal • \(meal.carbs)g C • \(meal.protein)g P • \(meal.fats)g F")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if showDate {
                    Text(meal.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if showType {
                    Text(meal.mealType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MealCardView_Previews: PreviewProvider {
    static var previews: some View {
        MealCardView(
            meal: MealEntry(
                userID: "user123",
                date: Date(),
                foodName: "Avocado Toast",
                calories: 350,
                carbs: 30,
                protein: 8,
                fats: 18,
                isManualEntry: true,
                mealType: .breakfast
            ),
            showDate: true,
            showType: true,
            favourites: []
        )
    }
}
