import SwiftUI

struct EditCalorieGoalView: View {
    // MARK: - Binding to UserModel
    @Binding var user: UserModel

    // MARK: - State
    @State private var newCalorieGoal: String = ""
    @State private var autoCalculate: Bool = false
    @State private var selectedMacroPreset: String = "Balanced (50/25/25)"
    @State private var selectedMealPreset: String = "Standard (25/35/30/10)"
    @State private var autoMealSplit: Bool = false

    let macroPresets = UserModel.macroPresets
    let mealPresets = UserModel.mealPresets

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            // MARK: - Calorie Goal Input
            Section(header: Text("Set Your Daily Calorie Goal")) {
                TextField("Enter new calorie goal", text: $newCalorieGoal)
                    .keyboardType(.numberPad)
                    .onChange(of: newCalorieGoal) { _ in
                        if autoCalculate {
                            updateCalorieGoal()
                        }
                    }

                Toggle("Auto-Calculate Macros", isOn: $autoCalculate)
                    .onChange(of: autoCalculate) { _ in
                        if autoCalculate {
                            applyMacroPreset()
                        }
                    }
            }

            if autoCalculate {
                // MARK: - Macro Presets
                Section(header: Text("Macro Presets")) {
                    Picker("Select a Preset", selection: $selectedMacroPreset) {
                        ForEach(macroPresets.keys.sorted(), id: \.self) { preset in
                            Text(preset)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedMacroPreset) { _ in
                        applyMacroPreset()
                    }
                }
            }

            // MARK: - Macronutrient Values
            Section(header: Text("Macronutrient Targets (%)")) {
                Text("Carbs: \(Int(user.carbPercentage))%")
                Text("Protein: \(Int(user.proteinPercentage))%")
                Text("Fats: \(Int(user.fatPercentage))%")
            }

            // MARK: - Meal Distribution
            Section(header: Text("Meal Distribution")) {
                Toggle("Auto-Split Meals", isOn: $autoMealSplit)
                    .onChange(of: autoMealSplit) { _ in
                        if autoMealSplit {
                            applyMealPreset()
                        }
                    }

                if autoMealSplit {
                    Picker("Meal Split Preset", selection: $selectedMealPreset) {
                        ForEach(mealPresets.keys.sorted(), id: \.self) { preset in
                            Text(preset)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedMealPreset) { _ in
                        applyMealPreset()
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text("Breakfast: \(Int(user.breakfastPercentage))%")
                        Text("Lunch: \(Int(user.lunchPercentage))%")
                        Text("Dinner: \(Int(user.dinnerPercentage))%")
                        Text("Snacks: \(Int(user.snackPercentage))%")
                    }
                }
            }

            // MARK: - Save Button
            Section {
                Button(action: saveChanges) {
                    Text("Save Changes")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .navigationTitle("Edit Nutrition Goals")
        .onAppear {
            newCalorieGoal = String(user.calorieGoal)
            autoCalculate = true
            selectedMacroPreset = user.selectedPreset ?? "Balanced (50/25/25)"
            selectedMealPreset = user.mealDistributionPreset ?? "Standard (25/35/30/10)"
        }
    }

    // MARK: - Update Calorie Goal
    private func updateCalorieGoal() {
        if let calorieInt = Int(newCalorieGoal), calorieInt > 0 {
            user.calorieGoal = calorieInt
        }
    }

    // MARK: - Apply Macro Preset
    private func applyMacroPreset() {
        if let (carb, protein, fat) = macroPresets[selectedMacroPreset] {
            user.carbPercentage = carb
            user.proteinPercentage = protein
            user.fatPercentage = fat
            user.selectedPreset = selectedMacroPreset
        }
    }

    // MARK: - Apply Meal Preset
    private func applyMealPreset() {
        if let (breakfast, lunch, dinner, snack) = mealPresets[selectedMealPreset] {
            user.breakfastPercentage = breakfast
            user.lunchPercentage = lunch
            user.dinnerPercentage = dinner
            user.snackPercentage = snack
            user.mealDistributionPreset = selectedMealPreset
        }
    }

    // MARK: - Save Changes
    private func saveChanges() {
        if let newGoal = Int(newCalorieGoal), newGoal > 0 {
            user.calorieGoal = newGoal
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Preview
struct EditCalorieGoalView_Previews: PreviewProvider {
    @State static var previewUser = UserModel(
        id: "test",
        firstName: "Val",
        lastName: "User",
        email: "test@example.com"
    )

    static var previews: some View {
        NavigationView {
            EditCalorieGoalView(user: $previewUser)
        }
    }
}
