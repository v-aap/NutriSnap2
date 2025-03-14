import SwiftUI

struct MealListView: View {
    @State private var selectedDate: Date = Date()
    @State private var selectedMealType: String? = nil
    @State private var showDatePicker = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter
    }()
    
    @State private var meals: [MealEntry] = [
        MealEntry(date: parseDate("2025-03-01"), foodName: "Avocado Toast", calories: 350, carbs: 40, protein: 10, fats: 15, isManualEntry: true, mealType: "Breakfast"),
        MealEntry(date: parseDate("2025-03-01"), foodName: "Grilled Salmon", calories: 600, carbs: 20, protein: 50, fats: 25, isManualEntry: false, mealType: "Lunch"),
        MealEntry(date: parseDate("2025-03-02"), foodName: "Omelette", calories: 300, carbs: 30, protein: 15, fats: 10, isManualEntry: true, mealType: "Breakfast"),
        MealEntry(date: parseDate("2025-03-02"), foodName: "Chicken Caesar Salad", calories: 450, carbs: 20, protein: 40, fats: 10, isManualEntry: false, mealType: "Lunch"),
    ]

    private var filteredMeals: [MealEntry] {
        meals.filter { meal in
            Calendar.current.isDate(meal.date, inSameDayAs: selectedDate) &&
            (selectedMealType == nil || meal.mealType == selectedMealType!)
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            // ✅ Date Header with Buttons & Clickable Date
            HStack {
                Button(action: { selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)! }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // ✅ Tap to open DatePicker
                Text(selectedDate, formatter: dateFormatter)
                    .font(.title3)
                    .bold()
                    .onTapGesture {
                        showDatePicker = true
                    }

                Spacer()
                
                Button(action: { selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)! }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top, 15) // Ensure spacing at the top

            // ✅ Meal Type Filter (Segmented Control)
            Picker("Meal Type", selection: $selectedMealType) {
                Text("All").tag(nil as String?)
                Text("Breakfast").tag("Breakfast" as String?)
                Text("Lunch").tag("Lunch" as String?)
                Text("Dinner").tag("Dinner" as String?)
                Text("Snack").tag("Snack" as String?)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // ✅ Meal List (Takes Full Space)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures proper layout
            }
        }
        .navigationBarTitleDisplayMode(.inline) // ✅ Keeps things neat
        .frame(maxHeight: .infinity, alignment: .top) // ✅ Keeps content at the top

        // ✅ Date Picker as Sheet (Fixed)
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
            .interactiveDismissDisabled(false) // Swipe down dismiss
        }
    }

    // ✅ Function to Parse Date
    private static func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }
}

// MARK: - Preview
struct MealListView_Previews: PreviewProvider {
    static var previews: some View {
        MealListView()
    }
}
