import SwiftUI

struct MealDetailView: View {
    var meal: MealEntry
    @State private var navigateToEdit = false

    var body: some View {
        VStack {
            Text(meal.foodName)
                .font(.largeTitle)
                .padding()

            Text("Calories: \(meal.calories)")
                .font(.title2)
                .padding()

            Text("Carbs: \(meal.carbs)g | Protein: \(meal.protein)g | Fats: \(meal.fats)g")
                .font(.body)
                .foregroundColor(.gray)
                .padding()

            Text("Date: \(meal.date, style: .date)")
                .font(.body)
                .foregroundColor(.gray)

            Spacer()

            Button(action: {
                navigateToEdit = true
            }) {
                Text("Edit Meal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Meal Details")
        .fullScreenCover(isPresented: $navigateToEdit) {
            MealEntryView(meal: meal) // ✅ Opens MealEntryView for editing
        }
    }
}

// MARK: - Preview
struct MealDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MealDetailView(meal: MealEntry(
                date: Date(),
                foodName: "Example Meal",
                calories: 500,
                carbs: 40,
                protein: 35,
                fats: 20,
                isManualEntry: true,
                mealType: "Breakfast"
            ))
        }
    }
}
