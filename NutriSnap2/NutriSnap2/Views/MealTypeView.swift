import SwiftUI

// MARK: - MealType Enum
enum MealType: String, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var id: String { rawValue }
}

// MARK: - Meal Model
struct Meal: Identifiable {
    let id = UUID()
    let name: String
    let type: MealType
    let date: Date
    let imageName: String?
}

// MARK: - MealTypeView 
/// Shows a list of meals for the day + filtering by meal type.
struct MealTypeView: View {
    
    // MARK: - State
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false
    
    // If `mealTypeFilter` is nil, show all meal types
    @State private var mealTypeFilter: MealType? = nil
    
    // MARK: - Dummy Data (3 days + 1 from a week earlier)
    private let allMeals: [Meal] = [
        // --- Day 1: 2025-03-01 ---
        Meal(name: "Avocado Toast",         type: .breakfast, date: sampleDate("2025-03-01"), imageName: "photo"),
        Meal(name: "Grilled Salmon",        type: .lunch,     date: sampleDate("2025-03-01"), imageName: "photo"),
        Meal(name: "Chicken Wrap",          type: .lunch,     date: sampleDate("2025-03-01"), imageName: "photo"),
        Meal(name: "Spaghetti Bolognese",   type: .dinner,    date: sampleDate("2025-03-01"), imageName: "photo"),
        Meal(name: "Fruit Salad",           type: .snack,     date: sampleDate("2025-03-01"), imageName: "photo"),
        Meal(name: "Protein Shake",         type: .snack,     date: sampleDate("2025-03-01"), imageName: "photo"),
        
        // --- Day 2: 2025-03-02 ---
        Meal(name: "Omelette",              type: .breakfast, date: sampleDate("2025-03-02"), imageName: "photo"),
        Meal(name: "Chicken Caesar Salad",  type: .lunch,     date: sampleDate("2025-03-02"), imageName: "photo"),
        Meal(name: "Turkey Sandwich",       type: .lunch,     date: sampleDate("2025-03-02"), imageName: "photo"),
        Meal(name: "Steak & Veggies",       type: .dinner,    date: sampleDate("2025-03-02"), imageName: "photo"),
        Meal(name: "Greek Yogurt",          type: .snack,     date: sampleDate("2025-03-02"), imageName: "photo"),
        
        // --- Day 3: 2025-02-28 ---
        Meal(name: "Pancakes",              type: .breakfast, date: sampleDate("2025-02-28"), imageName: "photo"),
        Meal(name: "Tuna Sandwich",         type: .lunch,     date: sampleDate("2025-02-28"), imageName: "photo"),
        Meal(name: "Burrito Bowl",          type: .dinner,    date: sampleDate("2025-02-28"), imageName: "photo"),
        Meal(name: "Fruit Smoothie",        type: .snack,     date: sampleDate("2025-02-28"), imageName: "photo"),
        Meal(name: "Popcorn",               type: .snack,     date: sampleDate("2025-02-28"), imageName: "photo"),
        
        // --- One week earlier: 2025-02-23 ---
        Meal(name: "French Toast",          type: .breakfast, date: sampleDate("2025-02-23"), imageName: "photo"),
        Meal(name: "Sushi Roll",            type: .lunch,     date: sampleDate("2025-02-23"), imageName: "photo"),
        Meal(name: "Tacos",                 type: .dinner,    date: sampleDate("2025-02-23"), imageName: "photo"),
        Meal(name: "Apple Slices",          type: .snack,     date: sampleDate("2025-02-23"), imageName: "photo"),
        Meal(name: "Cookies",               type: .snack,     date: sampleDate("2025-02-23"), imageName: "photo")
    ]
    
    // MARK: - Filtered Meals
    private var filteredMeals: [Meal] {
        allMeals.filter { meal in
            // 1) Same day as selectedDate
            Calendar.current.isDate(meal.date, inSameDayAs: selectedDate)
            // 2) Matches mealTypeFilter if set
            && (mealTypeFilter == nil || meal.type == mealTypeFilter!)
        }
    }
    
    // MARK: - Date Formatter
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // MARK: - Top Bar (Left/Right Arrows + Centered Date)
                HStack {
                    // Left arrow (previous day)
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // Centered date (tap to open date picker)
                    Text(formattedDate)
                        .font(.headline)
                        .onTapGesture {
                            showDatePicker = true
                        }
                    
                    Spacer()
                    
                    // Right arrow (next day)
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                Divider()
                
                // MARK: - Meal Type Filter (Segmented Control)
                Picker("Meal Type", selection: $mealTypeFilter) {
                    Text("All").tag(nil as MealType?)
                    ForEach(MealType.allCases) { mealType in
                        Text(mealType.rawValue).tag(mealType as MealType?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // MARK: - List of Meals for Selected Date
                ScrollView {
                    if filteredMeals.isEmpty {
                        Text("No meals for this date.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            // Navigate to detail (MealLogView) on tap
                            ForEach(filteredMeals) { meal in
                                NavigationLink(destination: MealLogView(meal: meal)) {
                                    MealCardView(meal: meal)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
        // MARK: - DatePicker Sheet
        .sheet(isPresented: $showDatePicker) {
            VStack {
                Text("Select a Date")
                    .font(.headline)
                    .padding()
                
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                
                Button("Done") {
                    showDatePicker = false
                }
                .padding()
            }
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - MealCardView
struct MealCardView: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder image
            if let imageName = meal.imageName {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.headline)
                Text("\(meal.type.rawValue) - \(formatDate(meal.date))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // Format date as "dd/MM/yyyy"
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - MealLogView
/// Shows more information about a specific meal/snack (macro nutrients, donut chart, etc.)
struct MealLogView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let meal: Meal
    
    // Dummy macro data keyed by meal name
    // totalCalories, carbs, protein, fat
    private let mealDetails: [String: (Int, Int, Int, Int)] = [
        "Avocado Toast":         (500, 50, 30, 20),
        "Grilled Salmon":        (600, 10, 40, 35),
        "Chicken Wrap":          (550, 40, 35, 25),
        "Spaghetti Bolognese":   (700, 80, 30, 25),
        "Fruit Salad":           (200, 45, 3, 2),
        "Protein Shake":         (300, 10, 40, 5),
        "Omelette":              (400, 10, 25, 22),
        "Chicken Caesar Salad":  (350, 20, 25, 15),
        "Turkey Sandwich":       (450, 35, 30, 18),
        "Steak & Veggies":       (650, 25, 50, 30),
        "Greek Yogurt":          (150, 15, 10, 2),
        "Pancakes":              (500, 70, 10, 10),
        "Tuna Sandwich":         (450, 40, 25, 15),
        "Burrito Bowl":          (600, 65, 25, 20),
        "Fruit Smoothie":        (250, 50, 5, 1),
        "Popcorn":               (180, 30, 3, 6),
        "French Toast":          (550, 60, 15, 20),
        "Sushi Roll":            (400, 50, 20, 5),
        "Tacos":                 (550, 40, 30, 20),
        "Apple Slices":          (100, 25, 0, 0),
        "Cookies":               (300, 40, 4, 12)
    ]
    
    // Format the meal date as "dd/MM/yyyy"
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: meal.date)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                // Meal name, type, date
                VStack(spacing: 4) {
                    Text(meal.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(meal.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)
                
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                
                // Donut Chart + Macros
                if let detail = mealDetails[meal.name] {
                    DonutChartView(
                        totalCalories: detail.0,
                        carbs: detail.1,
                        protein: detail.2,
                        fat: detail.3
                    )
                    .frame(height: 300)
                } else {
                    Text("No macro data found.")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Edit / Delete
                HStack(spacing: 40) {
                    Button {
                        // Implement Edit logic
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button {
                        // Implement Delete logic
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                        .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
            })
        }
    }
}

// MARK: - DonutChartView
/// A donut chart showing carbs/protein/fat, with total calories in the center.
struct DonutChartView: View {
    let totalCalories: Int
    let carbs: Int
    let protein: Int
    let fat: Int
    
    private var totalMacros: CGFloat {
        CGFloat(carbs + protein + fat)
    }
    
    private var carbsFraction: CGFloat {
        totalMacros == 0 ? 0 : CGFloat(carbs) / totalMacros
    }
    private var proteinFraction: CGFloat {
        totalMacros == 0 ? 0 : CGFloat(protein) / totalMacros
    }
    private var fatFraction: CGFloat {
        totalMacros == 0 ? 0 : CGFloat(fat) / totalMacros
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Donut Chart
            ZStack {
                // Carbs arc
                DonutArc(
                    startAngle: .degrees(0),
                    endAngle: .degrees(360 * Double(carbsFraction)),
                    color: .green
                )
                
                // Protein arc
                DonutArc(
                    startAngle: .degrees(360 * Double(carbsFraction)),
                    endAngle: .degrees(360 * Double(carbsFraction + proteinFraction)),
                    color: .blue
                )
                
                // Fat arc
                DonutArc(
                    startAngle: .degrees(360 * Double(carbsFraction + proteinFraction)),
                    endAngle: .degrees(360 * Double(carbsFraction + proteinFraction + fatFraction)),
                    color: .red
                )
                
                // Center text
                VStack {
                    Text("\(totalCalories) kcal")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .frame(width: 200, height: 200)
            
            // Macro legend
            VStack(spacing: 8) {
                HStack {
                    Text("Carbs")
                        .foregroundColor(.green)
                    Spacer()
                    Text("\(carbs) g")
                }
                HStack {
                    Text("Protein")
                        .foregroundColor(.blue)
                    Spacer()
                    Text("\(protein) g")
                }
                HStack {
                    Text("Fat")
                        .foregroundColor(.red)
                    Spacer()
                    Text("\(fat) g")
                }
            }
            .font(.headline)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - DonutArc
/// Draws a single arc for the donut chart
struct DonutArc: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    let lineWidth: CGFloat = 40
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(Color.clear, lineWidth: lineWidth)
                Circle()
                    .trim(
                        from: CGFloat(startAngle.degrees / 360),
                        to: CGFloat(endAngle.degrees / 360)
                    )
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: size, height: size)
        }
    }
}

// MARK: - Helper for Sample Data
private func sampleDate(_ dateString: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: dateString) ?? Date()
}

// MARK: - Preview
struct MealTypeView_Previews: PreviewProvider {
    static var previews: some View {
        MealTypeView()
    }
}
