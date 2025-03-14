import SwiftUI

struct SplashScreenView: View {
    @State private var showSignUp = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // MARK: - Logo Area
                ZStack {
                    // 1) Optional circle placeholder
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                        .frame(width: 120, height: 120)
                    
                    // 2) Real image (uncomment if you have an image named "my_logo" in Assets)
                    
                    Image("my_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    
                }
                
                // MARK: - App Name
                Text("NutriSnap")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // MARK: - Team Members
                VStack(spacing: 4) {
                    Text("Oscar Piedrasanta Diaz")
                    Text("Valeria Arce")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            
            // MARK: - Navigation to SignUpView
            .onAppear {
                // Automatically show SignUpView after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSignUp = true
                }
            }
            .fullScreenCover(isPresented: $showSignUp) {
                SignUpView()  // Launch your sign-up screen
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
