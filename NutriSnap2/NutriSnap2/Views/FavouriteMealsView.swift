import SwiftUI
import FirebaseAuth

struct FavouriteMealsView: View {
    var onSelectFavorite: (FavoriteMeal) -> Void

    @State private var favorites: [FavoriteMeal] = []
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var pendingDeleteIndex: Int? = nil
    @State private var searchText: String = ""
    @State private var selectedMealType: MealType? = nil

    var filteredFavourites: [FavoriteMeal] {
        favorites.filter { favourite in
            (searchText.isEmpty || favourite.foodName.lowercased().contains(searchText.lowercased())) &&
            (selectedMealType == nil || favourite.mealType == selectedMealType)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Search Field
                TextField("Search favourites...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // Meal Type Filter (iOS-style)
                Picker("Meal Type", selection: $selectedMealType) {
                    Text("All").tag(nil as MealType?)
                    ForEach(MealType.allCases, id: \ .self) { type in
                        Text(type.rawValue).tag(type as MealType?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Favourites List
                List {
                    ForEach(filteredFavourites) { favourite in
                        Button(action: {
                            onSelectFavorite(favourite)
                        }) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(favourite.foodName)
                                        .font(.headline)
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .imageScale(.small)
                                        Text(favourite.mealType.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Text("\(favourite.calories) kcal • \(favourite.carbs)g C • \(favourite.protein)g P • \(favourite.fats)g F")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: confirmDelete)
                }
            }
            .navigationTitle("Favourite Meals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { _ in errorMessage = nil }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
            .alert("Remove Favourite", isPresented: Binding<Bool>(
                get: { pendingDeleteIndex != nil },
                set: { newValue in if (!newValue) { pendingDeleteIndex = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let index = pendingDeleteIndex {
                        deleteFavourite(at: IndexSet(integer: index))
                        pendingDeleteIndex = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    pendingDeleteIndex = nil
                }
            } message: {
                Text("Are you sure you want to remove this meal from your favourites?")
            }
            .onAppear {
                fetchFavourites()
            }
        }
    }

    private func fetchFavourites() {
        isLoading = true
        FirestoreService.shared.fetchFavoriteMeals { fetched in
            isLoading = false
            self.favorites = fetched
        }
    }

    private func confirmDelete(at offsets: IndexSet) {
        if let first = offsets.first {
            pendingDeleteIndex = first
        }
    }

    private func deleteFavourite(at offsets: IndexSet) {
        for index in offsets {
            let favourite = favorites[index]
            FirestoreService.shared.deleteFavoriteMeal(favoriteID: favourite.id) { success in
                if success {
                    favorites.remove(at: index)
                } else {
                    self.errorMessage = "Failed to delete."
                }
            }
        }
    }
}

struct FavouriteMealsView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteMealsView(onSelectFavorite: { _ in })
    }
}

// MARK: - Favourite Matching Helper
extension FavoriteMeal {
    func isSame(as meal: MealEntry) -> Bool {
        return self.foodName == meal.foodName &&
               self.calories == meal.calories &&
               self.carbs == meal.carbs &&
               self.protein == meal.protein &&
               self.fats == meal.fats &&
               self.mealType == meal.mealType
    }
} 
