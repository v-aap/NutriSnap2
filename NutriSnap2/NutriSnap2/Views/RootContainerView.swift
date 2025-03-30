import SwiftUI

struct RootContainerView: View {
    @State private var selectedTab: Int = 0  // 0 = Dashboard, 1 = Favourites, 2 = Log, 3 = Meals, 4 = Profile
    @State private var selectedFavoriteMeal: FavoriteMeal? = nil
    @State private var showMealEntry = false

    var body: some View {
        VStack(spacing: 0) {

            TabView(selection: $selectedTab) {

                // Dashboard
                DashboardView()
                    .tag(0)

                // Favourites
                NavigationView {
                    FavouriteMealsView(onSelectFavorite: { meal in
                        selectedFavoriteMeal = meal
                        selectedTab = 2
                        showMealEntry = true
                    })
                    .navigationTitle("Favourites")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tag(1)

                // Log
                NavigationView {
                    ZStack {
                        LogView()
                            .navigationTitle("Log")
                            .navigationBarTitleDisplayMode(.inline)

                        NavigationLink(destination:
                            MealEntryView(meal: MealEntry(from: selectedFavoriteMeal ?? FavoriteMeal.placeholder)),
                            isActive: $showMealEntry
                        ) {
                            EmptyView()
                        }
                    }
                }
                .tag(2)

                // Meals
                NavigationView {
                    MealListView()
                        .navigationTitle("Meals")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tag(3)

                // Profile
                NavigationView {
                    ProfileView()
                        .navigationTitle("Profile")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tag(4)
            }
            .edgesIgnoringSafeArea(.bottom)

            // Custom Bottom Nav Bar
            ZStack {
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .frame(height: 1)
                    .edgesIgnoringSafeArea(.horizontal)

                HStack(spacing: 0) {
                    Spacer()

                    Button(action: { selectedTab = 0 }) {
                        Image(systemName: "house.fill")
                    }
                    .foregroundColor(selectedTab == 0 ? .blue : .gray)

                    Spacer()

                    Button(action: { selectedTab = 1 }) {
                        Image(systemName: "star.fill")
                    }
                    .foregroundColor(selectedTab == 1 ? .blue : .gray)

                    Spacer()

                    Button(action: { selectedTab = 2 }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 60, height: 60)
                                .shadow(radius: 4)
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 28, weight: .bold))
                        }
                    }
                    .offset(y: -20)

                    Spacer()

                    Button(action: { selectedTab = 3 }) {
                        Image(systemName: "fork.knife")
                    }
                    .foregroundColor(selectedTab == 3 ? .blue : .gray)

                    Spacer()

                    Button(action: { selectedTab = 4 }) {
                        Image(systemName: "person.crop.circle")
                    }
                    .foregroundColor(selectedTab == 4 ? .blue : .gray)

                    Spacer()
                }
                .padding(.bottom, 8)
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
    }
}

struct RootContainerView_Previews: PreviewProvider {
    static var previews: some View {
        RootContainerView()
    }
}

extension FavoriteMeal {
    static var placeholder: FavoriteMeal {
        FavoriteMeal(userID: "", foodName: "", calories: 0, carbs: 0, protein: 0, fats: 0, mealType: .breakfast)
    }
}
