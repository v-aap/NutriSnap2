import SwiftUI
import FirebaseAuth

struct MealEntryView: View {
    
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode  // Allows dismissing the view

    // MARK: - State Variables (Now Uses MealEntry Model)
    @State var meal: MealEntry

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Meal Type Picker
            Text("Meal Type")
                .font(.headline)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.white))
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )

                Picker("Select Type", selection: $meal.mealType) {
                    ForEach(MealEntry.mealTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Dropdown style
                .frame(height: 44)
                .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            
            // MARK: - Food Name
            Text("Food Name")
                .font(.headline)
            
            CustomTextField(placeholder: "e.g., Chicken Salad", text: $meal.foodName)
            
            // MARK: - Calories Input
            Text("Calories (kcal)")
                .font(.headline)
            
            CustomNumberField(placeholder: "Enter calories", value: $meal.calories)
            
            // MARK: - Macronutrients
            Text("Macronutrients")
                .font(.headline)
            
            VStack(spacing: 10) {
                NutrientRow(label: "Carbohydrates (g)", value: $meal.carbs)
                NutrientRow(label: "Protein (g)", value: $meal.protein)
                NutrientRow(label: "Fats (g)", value: $meal.fats)
            }
            
            Spacer()
            
            // MARK: - Save Button
            Button(action: {
                if let userID = Auth.auth().currentUser?.uid {
                    meal.userID = userID // ✅ Ensure `userID` is set
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Title in center
            ToolbarItem(placement: .principal) {
                Text("Edit Meal")
                    .font(.headline)
            }
            
            // Dismiss Button (X) on top right
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
        }
    }
}

// MARK: - Preview (Fixed with `userID`)
struct MealEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MealEntryView(meal: MealEntry(
                userID: "testUserID", 
                date: Date(),
                foodName: "Example Meal",
                calories: 400,
                carbs: 50,
                protein: 30,
                fats: 10,
                isManualEntry: true,
                mealType: "Breakfast"
            ))
        }
    }
}
