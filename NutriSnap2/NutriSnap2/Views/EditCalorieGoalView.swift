import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct EditCalorieGoalView: View {
    // MARK: - Binding to UserModel
    @Binding var user: UserModel

    // MARK: - State
    @State private var newCalorieGoal: String = ""
    @State private var autoCalculate: Bool = true
    @State private var selectedMacroPreset: String = "Balanced (50/25/25)"
    @State private var selectedMealPreset: String = "Standard (25/35/30/10)"
    @State private var autoMealSplit: Bool = true
    @State private var macroPresets: [String: (Double, Double, Double)] = UserModel.macroGramsPreset(for: 2000)

    @State private var carbInput: String = ""
    @State private var proteinInput: String = ""
    @State private var fatInput: String = ""

    @State private var breakfastInput: String = ""
    @State private var lunchInput: String = ""
    @State private var dinnerInput: String = ""
    @State private var snackInput: String = ""

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
                            macroPresets = UserModel.macroGramsPreset(for: user.calorieGoal)
                            applyMacroPreset()
                        }
                    }

                Toggle("Auto-Calculate Macros", isOn: $autoCalculate)
                    .onChange(of: autoCalculate) { isOn in
                        if isOn {
                            applyMacroPreset()
                        } else {
                            user.carbGrams = Double(carbInput) ?? user.carbGrams
                            user.proteinGrams = Double(proteinInput) ?? user.proteinGrams
                            user.fatGrams = Double(fatInput) ?? user.fatGrams
                        }
                    }
            }

            if autoCalculate {
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

            // MARK: - Macronutrient Input
            Section(header: Text("Macronutrient Targets (grams)")) {
                HStack {
                    Text("Carbs")
                    Spacer()
                    TextField("g", text: $carbInput)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Protein")
                    Spacer()
                    TextField("g", text: $proteinInput)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Fats")
                    Spacer()
                    TextField("g", text: $fatInput)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }

            // MARK: - Meal Distribution
            Section(header: Text("Meal Distribution")) {
                Toggle("Auto-Split Meals", isOn: $autoMealSplit)
                    .onChange(of: autoMealSplit) { isOn in
                        if isOn {
                            applyMealPreset()
                        } else {
                            user.breakfastPercentage = Double(breakfastInput) ?? user.breakfastPercentage
                            user.lunchPercentage = Double(lunchInput) ?? user.lunchPercentage
                            user.dinnerPercentage = Double(dinnerInput) ?? user.dinnerPercentage
                            user.snackPercentage = Double(snackInput) ?? user.snackPercentage
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
                    HStack {
                        Text("Breakfast")
                        Spacer()
                        TextField("%", text: $breakfastInput)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Lunch")
                        Spacer()
                        TextField("%", text: $lunchInput)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Dinner")
                        Spacer()
                        TextField("%", text: $dinnerInput)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Snacks")
                        Spacer()
                        TextField("%", text: $snackInput)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
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
            if !user.hasSetGoal {
                user.calorieGoal = 2000
                user.selectedPreset = "Balanced (50/25/25)"
                user.mealDistributionPreset = "Standard (25/35/30/10)"
                applyMacroPreset()
                applyMealPreset()
            }

            newCalorieGoal = String(user.calorieGoal)
            selectedMacroPreset = user.selectedPreset ?? "Balanced (50/25/25)"
            selectedMealPreset = user.mealDistributionPreset ?? "Standard (25/35/30/10)"
            macroPresets = UserModel.macroGramsPreset(for: user.calorieGoal)

            carbInput = String(format: "%.0f", user.carbGrams)
            proteinInput = String(format: "%.0f", user.proteinGrams)
            fatInput = String(format: "%.0f", user.fatGrams)

            breakfastInput = String(format: "%.0f", user.breakfastPercentage)
            lunchInput = String(format: "%.0f", user.lunchPercentage)
            dinnerInput = String(format: "%.0f", user.dinnerPercentage)
            snackInput = String(format: "%.0f", user.snackPercentage)
        }
    }

    // MARK: - Update Calorie Goal
    private func updateCalorieGoal() {
        if let goal = Int(newCalorieGoal), goal > 0 {
            user.calorieGoal = goal
        }
    }

// MARK: - Apply Macro Preset
    private func applyMacroPreset() {
        let currentPresets = UserModel.macroGramsPreset(for: user.calorieGoal)
        if let (carbs, protein, fats) = currentPresets[selectedMacroPreset] {
            user.carbGrams = carbs
            user.proteinGrams = protein
            user.fatGrams = fats
            user.selectedPreset = selectedMacroPreset

            carbInput = String(format: "%.0f", carbs)
            proteinInput = String(format: "%.0f", protein)
            fatInput = String(format: "%.0f", fats)
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

            breakfastInput = String(format: "%.0f", breakfast)
            lunchInput = String(format: "%.0f", lunch)
            dinnerInput = String(format: "%.0f", dinner)
            snackInput = String(format: "%.0f", snack)
        }
    }

    // MARK: - Calculate Meal Calories
    private func caloriesForMeal(_ percentage: Double) -> Int {
        return Int(Double(user.calorieGoal) * (percentage / 100))
    }

    // MARK: - Save Changes
    private func saveChanges() {
        if let newGoal = Int(newCalorieGoal), newGoal > 0 {
            user.calorieGoal = newGoal
        }
        if !autoCalculate {
            user.carbGrams = Double(carbInput) ?? user.carbGrams
            user.proteinGrams = Double(proteinInput) ?? user.proteinGrams
            user.fatGrams = Double(fatInput) ?? user.fatGrams
        }
        if !autoMealSplit {
            user.breakfastPercentage = Double(breakfastInput) ?? user.breakfastPercentage
            user.lunchPercentage = Double(lunchInput) ?? user.lunchPercentage
            user.dinnerPercentage = Double(dinnerInput) ?? user.dinnerPercentage
            user.snackPercentage = Double(snackInput) ?? user.snackPercentage
        }
        user.hasSetGoal = true

        FirestoreService.shared.updateUserGoals(user) { success in
            if success {
                print("✅ Goals saved to Firestore.")
            } else {
                print("❌ Failed to save goals.")
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}
