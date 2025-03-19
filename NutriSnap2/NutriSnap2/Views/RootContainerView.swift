import SwiftUI

struct RootContainerView: View {
    @State private var selectedTab: Int = 0  // 0 = Dashboard, 1 = Log, 2 = Meals, 3 = Profile
    
    var body: some View {
        VStack(spacing: 0) {
            // Use a TabView so that each view preserves its state.
            TabView(selection: $selectedTab) {
                NavigationView {
                    DashboardView()
                        .navigationBarHidden(true) // ✅ Prevents unwanted space
                }
                .tag(0)
                
                NavigationView {
                    LogView()
                        .navigationBarHidden(true)
                }
                .tag(1)
                
                NavigationView {
                    MealListView()
                        .navigationBarHidden(true)
                }
                .tag(2)
                
                NavigationView {
                    ProfileView()
                        .navigationBarHidden(true)
                }
                .tag(3)
            }
            .tabViewStyle(DefaultTabViewStyle())
            
            // Custom Bottom Navigation Bar
            VStack(spacing: 0) {
                // ✅ Background-colored separator
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .frame(height: 1)
                    .edgesIgnoringSafeArea(.horizontal)
                
                HStack {
                    Button(action: { selectedTab = 0 }) {
                        VStack {
                            Image(systemName: "house.fill")
                            Text("Dashboard").font(.caption)
                        }
                    }
                    .foregroundColor(selectedTab == 0 ? .blue : .gray)
                    
                    Spacer()
                    
                    Button(action: { selectedTab = 1 }) {
                        VStack {
                            Image(systemName: "doc.text.fill")
                            Text("Log").font(.caption)
                        }
                    }
                    .foregroundColor(selectedTab == 1 ? .blue : .gray)
                    
                    Spacer()
                    
                    Button(action: { selectedTab = 2 }) {
                        VStack {
                            Image(systemName: "fork.knife")
                            Text("Meals").font(.caption)
                        }
                    }
                    .foregroundColor(selectedTab == 2 ? .blue : .gray)
                    
                    Spacer()
                    
                    Button(action: { selectedTab = 3 }) {
                        VStack {
                            Image(systemName: "person.crop.circle")
                            Text("Profile").font(.caption)
                        }
                    }
                    .foregroundColor(selectedTab == 3 ? .blue : .gray)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    struct RootContainerView_Previews: PreviewProvider {
        static var previews: some View {
            RootContainerView()
        }
    }
}
