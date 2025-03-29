import SwiftUI
import FirebaseAuth

struct MealDetailView: View {
    var meal: MealEntry
    @State private var navigateToEdit = false
    @State private var showDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    var onDelete: ((MealEntry) -> Void)?
    
    @State private var isFavorite = false
    @State private var favoriteDocID: UUID? = nil
    @State private var isLoadingFavoriteStatus = true

    var body: some View {
        VStack {
            Text(meal.foodName)
                .font(.largeTitle)
                .bold()
                .padding()

            Text("Meal Type: \(meal.mealType.rawValue)")
                .font(.title2)
                .padding(.bottom, 5)

            PieChartView(carbs: meal.carbs, protein: meal.protein, fats: meal.fats, totalCalories: meal.calories)
                .frame(height: 250)
                .padding()

            Text("Date: \(meal.date, style: .date)")
                .font(.body)
                .foregroundColor(.gray)

            Spacer()

            HStack {
                Button(action: {
                    navigateToEdit = true
                }) {
                    Text("Edit Meal")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Meal")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 150, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Confirm Deletion"),
                        message: Text("Are you sure you want to delete this meal? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteMeal()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .navigationTitle("Meal Details")
        .navigationBarItems(trailing: favoriteStarButton)
        .onAppear {
            fetchFavoriteStatus()
        }
        .fullScreenCover(isPresented: $navigateToEdit) {
            MealEntryView(meal: meal)
        }
    }

    // MARK: - Favorite Star Icon
    private var favoriteStarButton: some View {
        Group {
            if !isLoadingFavoriteStatus {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .gray)
                }
            }
        }
    }

    // MARK: - Fetch Favorite Status
    private func fetchFavoriteStatus() {
        guard let userID = Auth.auth().currentUser?.uid else {
            isFavorite = false
            isLoadingFavoriteStatus = false
            return
        }

        FirestoreService.shared.fetchFavoriteMeals { favorites in
            if let match = favorites.first(where: { $0.isSame(as: meal) }) {
                self.isFavorite = true
                self.favoriteDocID = match.id
            } else {
                self.isFavorite = false
                self.favoriteDocID = nil
            }
            self.isLoadingFavoriteStatus = false
        }
    }

    // MARK: - Toggle Favorite
    private func toggleFavorite() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        if isFavorite {
            if let id = favoriteDocID {
                FirestoreService.shared.deleteFavoriteMeal(favoriteID: id) { success in
                    if success {
                        isFavorite = false
                        favoriteDocID = nil
                    }
                }
            }
        } else {
            let newFavorite = FavoriteMeal(
                userID: userID,
                foodName: meal.foodName,
                calories: meal.calories,
                carbs: meal.carbs,
                protein: meal.protein,
                fats: meal.fats,
                mealType: meal.mealType,
                photoURL: meal.photoURL
            )

            FirestoreService.shared.saveFavoriteMeal(newFavorite) { success, error in
                if success {
                    isFavorite = true
                    favoriteDocID = newFavorite.id
                }
            }
        }
    }

    private func deleteMeal() {
        onDelete?(meal)
        presentationMode.wrappedValue.dismiss()
    }
}
