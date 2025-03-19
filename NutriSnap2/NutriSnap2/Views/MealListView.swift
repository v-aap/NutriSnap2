import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MealListView: View {
    @State private var selectedDate: Date = Date()
    @State private var selectedMealType: String? = nil
    @State private var showDatePicker = false
    @State private var meals: [MealEntry] = []
    
    private let db = Firestore.firestore()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter
    }()
    
    private var filteredMeals: [MealEntry] {
        meals.filter { meal in
            Calendar.current.isDate(meal.date, inSameDayAs: selectedDate) &&
            (selectedMealType == nil || meal.mealType.rawValue == selectedMealType!)
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            
            // Date Header with Buttons & Clickable Date
            HStack {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(selectedDate, formatter: dateFormatter)
                    .font(.title3)
                    .bold()
                    .onTapGesture {
                        showDatePicker = true
                    }

                Spacer()
                
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            // Removed the old .padding(.top, 15) to reduce extra space under the nav bar

            // Meal Type Filter (Segmented Control)
            Picker("Meal Type", selection: $selectedMealType) {
                Text("All").tag(nil as String?)
                Text("Breakfast").tag("Breakfast" as String?)
                Text("Lunch").tag("Lunch" as String?)
                Text("Dinner").tag("Dinner" as String?)
                Text("Snack").tag("Snack" as String?)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Meal List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(filteredMeals, id: \.id) { meal in
                        NavigationLink(destination: MealDetailView(meal: meal)) {
                            MealCardView(meal: meal, showDate: false, showType: true)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            VStack {
                Text("Select a Date")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                DatePicker("Choose Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                Spacer()

                Button("Done") {
                    showDatePicker = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .presentationDetents([.large])
        }
        .onAppear {
            fetchMeals()
        }
    }

    private func fetchMeals() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ Error: No user logged in.")
            return
        }

        db.collection("meals")
            .whereField("userID", isEqualTo: userID)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching meals: \(error.localizedDescription)")
                    return
                }

                self.meals = snapshot?.documents.compactMap { doc -> MealEntry? in
                    let data = doc.data()
                    return MealEntry(
                        userID: data["userID"] as? String ?? "",
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        foodName: data["foodName"] as? String ?? "",
                        calories: data["calories"] as? Int ?? 0,
                        carbs: data["carbs"] as? Int ?? 0,
                        protein: data["protein"] as? Int ?? 0,
                        fats: data["fats"] as? Int ?? 0,
                        isManualEntry: data["isManualEntry"] as? Bool ?? true,
                        mealType: MealType(rawValue: data["mealType"] as? String ?? "Unknown") ?? .breakfast
                    )
                } ?? []
            }
    }
}

struct MealListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MealListView()
                .navigationTitle("Meals")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
