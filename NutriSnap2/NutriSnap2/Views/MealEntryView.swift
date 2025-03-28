import SwiftUI
import FirebaseAuth

struct MealEntryView: View {
    
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode  // Allows dismissing the view
    
    // MARK: - State Variables
    @State var meal: MealEntry
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // NEW: Controls whether the calendar sheet is presented
    @State private var showDatePicker = false
    
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
                    ForEach(MealType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Dropdown style
                .frame(height: 44)
                .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            
            // MARK: - Date Selection
            Text("Meal Date")
                .font(.headline)
            
            // Display the selected date & a button to open the calendar
            HStack {
                Text("\(meal.date, style: .date)")
                    .font(.body)
                
                Spacer()
                
                // Tap this to open the date picker (calendar)
                Button {
                    showDatePicker.toggle()
                } label: {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                }
            }
            // Sheet with a graphical calendar
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    Text("Select a Date")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    // Restrict to past dates & today. Remove `in: ...Date()` if you want future dates too.
                    DatePicker(
                        "",
                        selection: $meal.date,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .onChange(of: meal.date) { _ in
                        // Automatically close when a date is picked
                        showDatePicker = false
                    }
                }
                .padding()
            }
            
            // MARK: - Food Name Input
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
            Button(action: saveMeal) {
                Text("Save Meal")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
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
    
    // MARK: - Save Meal Function
    private func saveMeal() {
        // Ensure the user is logged in
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be logged in to save meals."
            showErrorAlert = true
            print("❌ No authenticated user!")
            return
        }
        
        print("📝 Attempting to save meal for user ID: \(userID)")
        
        // Validate Meal Type
        if let mealTypeError = ValidationService.mealTypeValidationMessage(meal.mealType.rawValue) {
            errorMessage = mealTypeError
            showErrorAlert = true
            print("❌ Meal type validation failed: \(mealTypeError)")
            return
        }
        
        // Validate Calories
        if meal.calories <= 0 {
            errorMessage = "Calories must be greater than 0."
            showErrorAlert = true
            print("❌ Invalid calories: \(meal.calories)")
            return
        }
        
        // Set user ID explicitly
        meal.userID = userID
        
        print("🔥 Saving Meal Entry: \(meal)")
        
        // Attempt to save the meal in Firestore
        FirestoreService.shared.saveMeal(meal: meal) { success, error in
            if success {
                print("✅ Meal successfully saved to Firestore!")
                presentationMode.wrappedValue.dismiss()
            } else {
                errorMessage = error ?? "Failed to save meal."
                showErrorAlert = true
                print("❌ Firestore write error: \(error ?? "Unknown error")")
            }
        }
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
                    mealType: .breakfast
                )
            )
        }
    }
}
