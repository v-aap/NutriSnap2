import SwiftUI

struct MealDetailView: View {
    var meal: MealEntry
    @State private var navigateToEdit = false
    @State private var showDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    var onDelete: ((MealEntry) -> Void)? // ✅ Closure to handle deletion externally

    var body: some View {
        VStack {
            Text(meal.foodName)
                .font(.largeTitle)
                .bold()
                .padding()

            Text("Meal Type: \(meal.mealType)")
                .font(.title2)
                .padding(.bottom, 5)

            // ✅ Pie Chart for Macronutrients
            PieChartView(carbs: meal.carbs, protein: meal.protein, fats: meal.fats, totalCalories: meal.calories)
                .frame(height: 250) // Adjust size as needed
                .padding()

            Text("Date: \(meal.date, style: .date)")
                .font(.body)
                .foregroundColor(.gray)

            Spacer()

            HStack {
                Button(action: {
                    navigateToEdit = true
                }) {
                    Text("Edit Meal")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Meal")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 150, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Confirm Deletion"),
                        message: Text("Are you sure you want to delete this meal? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteMeal()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .navigationTitle("Meal Details")
        .fullScreenCover(isPresented: $navigateToEdit) {
            MealEntryView(meal: meal) // ✅ Opens MealEntryView for editing
        }
    }

    // Delete meal and go back to previous screen
    private func deleteMeal() {
        onDelete?(meal) // ✅ Calls external deletion function
        presentationMode.wrappedValue.dismiss()
    }
}
