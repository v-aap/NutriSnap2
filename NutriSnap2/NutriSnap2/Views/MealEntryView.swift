import SwiftUI
import FirebaseAuth

// MARK: - Main MealEntryView
struct MealEntryView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    // State: the meal being edited/created
    @State var meal: MealEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Meal Type Picker
            Text("Meal Type")
                .font(.headline)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
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
                .pickerStyle(MenuPickerStyle())
                .frame(height: 44)
                .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            
            // MARK: - Date Picker
            Text("Date")
                .font(.headline)
            DatePicker("Select Date", selection: $meal.date, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding(.horizontal)
            
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
                // Ensure the current user is authenticated
                if let userID = Auth.auth().currentUser?.uid {
                    meal.userID = userID
                    // Use FirestoreService to save the meal
                    FirestoreService.shared.saveMeal(meal) { success in
                        if success {
                            print("Meal successfully added!")
                        } else {
                            print("Error adding meal.")
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    // If there's no user, just dismiss or handle it differently
                    presentationMode.wrappedValue.dismiss()
                }
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
            // Title in the center
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

// MARK: - CustomTextField
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)
    }
}

// MARK: - CustomNumberField
struct CustomNumberField: View {
    var placeholder: String
    @Binding var value: Int

    var body: some View {
        TextField(placeholder, value: $value, formatter: NumberFormatter())
            .keyboardType(.numberPad)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)
    }
}

// MARK: - NutrientRow
struct NutrientRow: View {
    var label: String
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            TextField("0", value: $value, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .frame(width: 50)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Preview
struct MealEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MealEntryView(
                meal: MealEntry(
                    userID: "testUserID",
                    date: Date(),
                    foodName: "Example Meal",
                    calories: 400,
                    carbs: 50,
                    protein: 30,
                    fats: 10,
                    isManualEntry: true,
                    mealType: "Breakfast",
                    photoURL: nil
                )
            )
        }
    }
}
