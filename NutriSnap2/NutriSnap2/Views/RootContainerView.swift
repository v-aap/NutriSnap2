import SwiftUI

struct RootContainerView: View {
    @State private var selectedTab: Int = 0  // 0 = Dashboard, 1 = Log, 2 = Meals, 3 = Profile
    @State private var layoutFixToggle: Bool = false  // Dummy state to force layout refresh

    var body: some View {
        TabView(selection: $selectedTab) {
            // 1) Dashboard — no NavigationView (custom header inside DashboardView)
            DashboardView()
                .tag(0)
            
            // 2) Log — standard nav bar
            NavigationView {
                LogView()
                    .navigationTitle("Log")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tag(1)
            
            // 3) Meals — standard nav bar
            NavigationView {
                MealListView()
                    .navigationTitle("Meals")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tag(2)
            
            // 4) Profile — standard nav bar
            NavigationView {
                ProfileView()
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tag(3)
        }
        // Force a re-render when layoutFixToggle changes
        .id(layoutFixToggle)
        // Use safeAreaInset for the custom bottom bar
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                // Top divider for the bar
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .frame(height: 1)
                    .edgesIgnoringSafeArea(.horizontal)
                
                HStack {
                    Button(action: { selectedTab = 0 }) {
                        VStack {
                            Image(systemName: "house.fill")
                            Text("Dashboard")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(selectedTab == 0 ? .blue : .gray)
                    
                    Spacer()
                    
                    Button(action: { selectedTab = 1 }) {
                        VStack {
                            Image(systemName: "doc.text.fill")
                            Text("Log")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(selectedTab == 1 ? .blue : .gray)
                    
                    Spacer()
                    
                    Button(action: { selectedTab = 2 }) {
                        VStack {
                            Image(systemName: "fork.knife")
                            Text("Meals")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(selectedTab == 2 ? .blue : .gray)
                    
                    Spacer()
                    
                    Button(action: { selectedTab = 3 }) {
                        VStack {
                            Image(systemName: "person.crop.circle")
                            Text("Profile")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(selectedTab == 3 ? .blue : .gray)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        // On first appearance, toggle the dummy state after a short delay to force layout refresh
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                layoutFixToggle.toggle()
            }
        }
        // Also refresh the layout when the app enters the foreground
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            layoutFixToggle.toggle()
        }
    }
}

struct RootContainerView_Previews: PreviewProvider {
    static var previews: some View {
        RootContainerView()
    }
}
