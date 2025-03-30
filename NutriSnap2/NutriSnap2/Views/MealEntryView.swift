import SwiftUI
import FirebaseAuth

struct MealEntryView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var meal: MealEntry
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showDatePicker = false
    @State private var showFavoriteSavedAlert = false

    @State private var allFavorites: [FavoriteMeal] = []
    @State private var showSuggestions = false

    var body: some View {
        Form {
            Section(header: Text("Meal Type")) {
                Picker("Meal Type", selection: $meal.mealType) {
                    ForEach(MealType.allCases, id: \.rawValue) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(.green)
            }

            Section(header: Text("Meal Date")) {
                HStack {
                    Text("\(meal.date, style: .date)")
                    Spacer()
                    Button {
                        showDatePicker.toggle()
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(.green)
                    }
                }
            }

            Section(header: Text("Food Name")) {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("e.g., Chicken Salad", text: $meal.foodName)
                        .onChange(of: meal.foodName) { _ in
                            showSuggestions = !filteredFavorites.isEmpty
                        }

                    if showSuggestions {
                        ForEach(filteredFavorites, id: \.id) { favorite in
                            Button(action: {
                                fillFromFavorite(favorite)
                            }) {
                                VStack(alignment: .leading) {
                                    Text(favorite.foodName)
                                        .fontWeight(.medium)
                                    Text("\(favorite.calories) kcal • \(favorite.carbs)g C • \(favorite.protein)g P • \(favorite.fats)g F")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }

            Section(header: Text("Calories (kcal)")) {
                TextField("Enter calories", value: $meal.calories, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
            }

            Section(header: Text("Macronutrients (grams)")) {
                HStack {
                    Text("Carbs (g)")
                    Spacer()
                    TextField("g", value: $meal.carbs, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Protein (g)")
                    Spacer()
                    TextField("g", value: $meal.protein, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Fats (g)")
                    Spacer()
                    TextField("g", value: $meal.fats, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }


            Section {
                Button("Save Meal") {
                    saveMeal()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(8)
            }
        }
        .navigationBarTitle("Log Meal", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.green)
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            VStack {
                Text("Select a Date")
                    .font(.headline)
                    .padding(.bottom, 8)

                DatePicker("", selection: $meal.date, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .onChange(of: meal.date) { _ in
                        showDatePicker = false
                    }
            }
            .padding()
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            FirestoreService.shared.fetchFavoriteMeals { fetched in
                self.allFavorites = fetched
            }
        }
    }

    private var filteredFavorites: [FavoriteMeal] {
        guard !meal.foodName.isEmpty else { return [] }
        return allFavorites.filter { $0.foodName.lowercased().contains(meal.foodName.lowercased()) }
    }

    private func fillFromFavorite(_ favorite: FavoriteMeal) {
        meal.foodName = favorite.foodName
        meal.calories = favorite.calories
        meal.carbs = favorite.carbs
        meal.protein = favorite.protein
        meal.fats = favorite.fats
        meal.mealType = favorite.mealType
        meal.photoURL = favorite.photoURL
        showSuggestions = false
    }

    private func saveMeal() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be logged in to save meals."
            showErrorAlert = true
            return
        }

        if let mealTypeError = ValidationService.mealTypeValidationMessage(meal.mealType.rawValue) {
            errorMessage = mealTypeError
            showErrorAlert = true
            return
        }

        if meal.calories <= 0 {
            errorMessage = "Calories must be greater than 0."
            showErrorAlert = true
            return
        }

        meal.userID = userID

        FirestoreService.shared.saveMeal(meal: meal) { success, error in
            if success {
                presentationMode.wrappedValue.dismiss()
            } else {
                errorMessage = error ?? "Failed to save meal."
                showErrorAlert = true
            }
        }
    }
}

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
