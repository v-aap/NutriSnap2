import SwiftUI

struct EditCalorieGoalView: View {
    // MARK: - Binding to Model
    @Binding var nutritionGoal: NutritionGoal

    // MARK: - State
    @State private var newCalorieGoal: String = ""
    @State private var autoCalculate: Bool = false
    @State private var selectedPreset: String = "Balanced"

    let presets = [
        "Balanced (50/25/25)": (50.0, 25.0, 25.0),
        "High-Protein (40/35/25)": (40.0, 35.0, 25.0),
        "Low-Carb (30/35/35)": (30.0, 35.0, 35.0),
        "Keto (10/30/60)": (10.0, 30.0, 60.0)
    ]

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            // MARK: - Calorie Goal Input
            Section(header: Text("Set Your Daily Calorie Goal")) {
                TextField("Enter new calorie goal", text: $newCalorieGoal)
                    .keyboardType(.numberPad)
                    .onChange(of: newCalorieGoal) { newValue in
                        if autoCalculate {
                            updateCalorieGoal()
                        }
                    }

                Toggle("Auto-Calculate Macros", isOn: $autoCalculate)
                    .onChange(of: autoCalculate) { newValue in
                        if newValue {
                            updateCalorieGoal()
                        }
                    }
            }

            if autoCalculate {
                // MARK: - Preset Selection
                Section(header: Text("Macro Presets")) {
                    Picker("Select a Preset", selection: $selectedPreset) {
                        ForEach(presets.keys.sorted(), id: \.self) { preset in
                            Text(preset)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedPreset) { newValue in
                        applyPreset()
                    }
                }
            }

            // MARK: - Macronutrient Inputs
            Section(header: Text("Macronutrient Goals (grams)")) {
                Text("Carbs: \(nutritionGoal.carbGrams)g")
                Text("Protein: \(nutritionGoal.proteinGrams)g")
                Text("Fats: \(nutritionGoal.fatGrams)g")
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
            newCalorieGoal = String(nutritionGoal.calorieGoal)
            autoCalculate = nutritionGoal.isAutoCalculated
            selectedPreset = nutritionGoal.selectedPreset
        }
    }

    // MARK: - Update Calorie Goal
    private func updateCalorieGoal() {
        if let calorieInt = Int(newCalorieGoal), calorieInt > 0 {
            nutritionGoal.calorieGoal = calorieInt
            nutritionGoal.calculateMacros()
        }
    }

    // MARK: - Apply Preset
    private func applyPreset() {
        if let (carb, protein, fat) = presets[selectedPreset] {
            nutritionGoal.carbPercentage = carb
            nutritionGoal.proteinPercentage = protein
            nutritionGoal.fatPercentage = fat
            nutritionGoal.selectedPreset = selectedPreset
            nutritionGoal.calculateMacros()
        }
    }

    // MARK: - Save Changes
    private func saveChanges() {
        if let newGoal = Int(newCalorieGoal), newGoal > 0 {
            nutritionGoal.calorieGoal = newGoal
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Preview
struct EditCalorieGoalView_Previews: PreviewProvider {
    @State static var nutritionGoal = NutritionGoal.defaultGoal

    static var previews: some View {
        NavigationView {
            EditCalorieGoalView(nutritionGoal: $nutritionGoal)
        }
    }
}
