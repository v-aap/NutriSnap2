import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct EditCalorieGoalView: View {
    @Binding var user: UserModel

    // MARK: - States
    @State private var newCalorieGoal: String = ""
    @State private var autoCalculate: Bool = true
    @State private var selectedMacroPreset: String = "Balanced (50/25/25)"
    @State private var selectedMealPreset: String = "Standard (25/35/30/10)"
    @State private var autoMealSplit: Bool = true
    @State private var macroPresets: [String: (Double, Double, Double)] = [:]

    @State private var carbInput: String = ""
    @State private var proteinInput: String = ""
    @State private var fatInput: String = ""

    @State private var breakfastInput: String = ""
    @State private var lunchInput: String = ""
    @State private var dinnerInput: String = ""
    @State private var snackInput: String = ""

    @State private var manualOverrideCalories: String? = nil

    let mealPresets = UserModel.mealPresets
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Body
    var body: some View {
        Form {
            calorieGoalSection
            macroPresetSection
            macronutrientInputSection
            mealDistributionSection
            saveButtonSection
        }
        .navigationTitle("Edit Nutrition Goals")
        .onAppear(perform: setupInitialValues)
    }

    // MARK: - Sections
    private var calorieGoalSection: some View {
        Section(header: Text("Set Your Daily Calorie Goal")) {
            TextField("Enter new calorie goal", text: $newCalorieGoal)
                .keyboardType(.numberPad)
                .onChange(of: newCalorieGoal) { newValue in
                    print("[TextField] newCalorieGoal changed to: \(newValue)")
                    if autoCalculate {
                        if let goal = Int(newValue), goal > 0 {
                            print("[AutoCalc] Updating macro presets for new goal: \(goal)")
                            macroPresets = UserModel.macroGramsPreset(for: goal)
                            applyMacroPreset()
                        }
                    } else {
                        manualOverrideCalories = newValue
                        print("[Manual Entry] Stored manualOverrideCalories = \(manualOverrideCalories ?? "")")
                    }
                }

            Toggle("Auto-Calculate Macros", isOn: $autoCalculate)
                .onChange(of: autoCalculate) { isOn in
                    print("[Toggle] Auto-Calculate toggled: \(isOn)")
                    if isOn {
                        let input = manualOverrideCalories ?? newCalorieGoal
                        if let goal = Int(input), goal > 0 {
                            print("[Toggle] Re-applying macro preset for calorie goal: \(goal)")
                            macroPresets = UserModel.macroGramsPreset(for: goal)
                            applyMacroPreset()
                            newCalorieGoal = input
                        }
                    }
                }
        }
    }

    private var macroPresetSection: some View {
        if autoCalculate {
            return AnyView(Section(header: Text("Macro Presets")) {
                Picker("Select a Preset", selection: $selectedMacroPreset) {
                    ForEach(macroPresets.keys.sorted(), id: \.self) { preset in
                        Text(preset)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedMacroPreset) { newPreset in
                    print("[Picker] Macro preset changed to: \(newPreset)")
                    if autoCalculate, let goal = Int(newCalorieGoal), goal > 0 {
                        print("[Picker] Updating macros using preset \(newPreset) for goal: \(goal)")
                        macroPresets = UserModel.macroGramsPreset(for: goal)
                        applyMacroPreset()
                    }
                }
            })
        } else {
            return AnyView(EmptyView())
        }
    }

    private var macronutrientInputSection: some View {
        Section(header: Text("Macronutrient Targets (grams)")) {
            macroInputField("Carbs", binding: $carbInput)
            macroInputField("Protein", binding: $proteinInput)
            macroInputField("Fats", binding: $fatInput)
        }
    }

    private var mealDistributionSection: some View {
        Section(header: Text("Meal Distribution (%)")) {
            Toggle("Auto-Split Meals", isOn: $autoMealSplit)
                .onChange(of: autoMealSplit) { isOn in
                    print("[Toggle] Auto Meal Split toggled: \(isOn)")
                }
            if autoMealSplit {
                Picker("Meal Split Preset", selection: $selectedMealPreset) {
                    ForEach(mealPresets.keys.sorted(), id: \.self) { Text($0) }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedMealPreset) { newValue in
                    print("[Picker] Meal preset changed to: \(newValue)")
                    applyMealPreset()
                }
            } else {
                mealInputField("Breakfast", binding: $breakfastInput)
                mealInputField("Lunch", binding: $lunchInput)
                mealInputField("Dinner", binding: $dinnerInput)
                mealInputField("Snacks", binding: $snackInput)

                if mealDistributionTotal() != 100 {
                    Text("Total: \(String(format: "%.0f", mealDistributionTotal()))%. Adjust to 100%.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }

    private var saveButtonSection: some View {
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

    // MARK: - Helpers
    private func updateCalorieGoalFromManualMacros() {
        guard !autoCalculate else {
            print("[Manual Macros] Skipped update due to autoCalculate being ON")
            return
        }
        let carbs = Double(carbInput) ?? 0
        let protein = Double(proteinInput) ?? 0
        let fat = Double(fatInput) ?? 0
        let totalCalories = (carbs * 4) + (protein * 4) + (fat * 9)
        print("[Manual Macros] C=\(carbs), P=\(protein), F=\(fat), Total=\(totalCalories)")
        user.calorieGoal = Int(totalCalories)
        newCalorieGoal = "\(Int(totalCalories))"
    }

    private func macroInputField(_ title: String, binding: Binding<String>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("g", text: binding)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .onChange(of: binding.wrappedValue) { newValue in
                    print("[Macro Input] \(title) changed to \(newValue)")
                    if autoCalculate {
                        print("[Macro Input] Auto-calculate disabled due to \(title) input")
                        DispatchQueue.main.async {
                            autoCalculate = false
                        }
                    }
                    DispatchQueue.main.async {
                        updateCalorieGoalFromManualMacros()
                    }
                }
        }
    }

    private func mealInputField(_ title: String, binding: Binding<String>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("%", text: binding)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .onChange(of: binding.wrappedValue) { newValue in
                    print("[Meal Input] \(title) changed to \(newValue)%")
                    autoMealSplit = false
                }
        }
    }

    private func setupInitialValues() {
        print("[Setup] Initializing UI with user model")
        if newCalorieGoal.isEmpty {
            newCalorieGoal = "\(user.calorieGoal)"
            print("[Setup] Set newCalorieGoal to \(newCalorieGoal)")
        }
        selectedMacroPreset = user.selectedPreset ?? "Balanced (50/25/25)"
        selectedMealPreset = user.mealDistributionPreset ?? "Standard (25/35/30/10)"
        macroPresets = UserModel.macroGramsPreset(for: user.calorieGoal)
        applyMacroPreset()
        applyMealPreset()
    }

    private func updateCalorieGoal() {
        if let goal = Int(newCalorieGoal), goal > 0 {
            print("[Update Goal] Manually set user.calorieGoal to \(goal)")
            user.calorieGoal = goal
        }
    }

    private func applyMacroPreset() {
        guard autoCalculate else {
            print("[Apply Macro] Skipped due to autoCalculate OFF")
            return
        }
        if let (carbs, protein, fats) = macroPresets[selectedMacroPreset] {
            print("[Apply Macro] \(selectedMacroPreset) → C=\(carbs), P=\(protein), F=\(fats)")
            user.carbGrams = carbs
            user.proteinGrams = protein
            user.fatGrams = fats
            user.selectedPreset = selectedMacroPreset
            carbInput = String(format: "%.0f", carbs)
            proteinInput = String(format: "%.0f", protein)
            fatInput = String(format: "%.0f", fats)
        }
    }

    private func applyMealPreset() {
        if let (breakfast, lunch, dinner, snack) = mealPresets[selectedMealPreset] {
            print("[Apply Meal] \(selectedMealPreset) → B=\(breakfast), L=\(lunch), D=\(dinner), S=\(snack)")
            user.updateMeals(breakfast: breakfast, lunch: lunch, dinner: dinner, snack: snack, preset: selectedMealPreset)
            breakfastInput = "\(Int(breakfast))"
            lunchInput = "\(Int(lunch))"
            dinnerInput = "\(Int(dinner))"
            snackInput = "\(Int(snack))"
        }
    }

    private func mealDistributionTotal() -> Double {
        let total = [breakfastInput, lunchInput, dinnerInput, snackInput].compactMap(Double.init).reduce(0, +)
        print("[Meal Total] Distribution = \(total)%")
        return total
    }

    private func saveChanges() {
        print("[Save] Saving user to Firestore...")
        user.saveToFirestore { success in
            print(success ? "✅ Goals saved." : "❌ Failed to save goals.")
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    EditCalorieGoalView(user: .constant(UserModel(
        id: "preview-user",
        firstName: "Test",
        lastName: "User",
        email: "test@example.com"
    )))
}
