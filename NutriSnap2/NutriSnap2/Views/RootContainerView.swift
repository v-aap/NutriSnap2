import SwiftUI

struct RootContainerView: View {
    @State private var selectedTab: Int = 0  // 0 = Dashboard, 1 = Log, 2 = Meals, 3 = Profile
    
    var body: some View {
        VStack(spacing: 0) {
            
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
                .tag(1)
                
                // 3) Meals — standard nav bar
                NavigationView {
                    MealListView()
                        .navigationTitle("Meals")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tag(2)
                
                // 4) Profile — standard nav bar
                NavigationView {
                    ProfileView()
                        .navigationTitle("Profile")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tag(3)
            }
            // Only ignore bottom safe area so the tab bar is flush
            .edgesIgnoringSafeArea(.bottom)
            
            // Custom Bottom Nav Bar
            VStack(spacing: 0) {
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
    }
}

struct RootContainerView_Previews: PreviewProvider {
    static var previews: some View {
        RootContainerView()
    }
}
