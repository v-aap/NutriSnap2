import SwiftUI
import FirebaseAuth

struct FavoriteMealsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var favorites: [FavoriteMeal] = []
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var pendingDeleteIndex: Int? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(favorites) { favorite in
                    VStack(alignment: .leading) {
                        Text(favorite.foodName)
                            .font(.headline)
                        Text("\(favorite.calories) kcal • \(favorite.carbs)g C • \(favorite.protein)g P • \(favorite.fats)g F")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: confirmDelete)
            }
            .navigationTitle("Favorite Meals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
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
            .alert("Remove Favorite", isPresented: Binding<Bool>(
                get: { pendingDeleteIndex != nil },
                set: { newValue in if !newValue { pendingDeleteIndex = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let index = pendingDeleteIndex {
                        deleteFavorite(at: IndexSet(integer: index))
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
                fetchFavorites()
            }
        }
    }

    private func fetchFavorites() {
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

    private func deleteFavorite(at offsets: IndexSet) {
        for index in offsets {
            let favorite = favorites[index]
            FirestoreService.shared.deleteFavoriteMeal(favoriteID: favorite.id) { success in
                if success {
                    favorites.remove(at: index)
                } else {
                    self.errorMessage = "Failed to delete."
                }
            }
        }
    }
}

struct FavoriteMealsView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteMealsView()
    }
}
