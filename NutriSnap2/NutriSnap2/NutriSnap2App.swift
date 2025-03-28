import SwiftUI
import FirebaseCore
import FirebaseAuth

// MARK: - Firebase Initialization (App Delegate)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("???? Firebase is configuring...")
        FirebaseApp.configure()
        print("Firebase configured successfully")
        return true
    }
}

@main
struct NutriSnap2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State private var isUserLoggedIn: Bool = false
    @State private var showSplash = true

    init() {
        print("App Initialized")
    }

    var body: some Scene {
        WindowGroup {
            // Remove the outer NavigationView and use a Group instead
            Group {
                if showSplash {
                    SplashScreenView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSplash = false
                            }
                        }
                } else {
                    if isUserLoggedIn {
                        RootContainerView()  // RootContainerView already has its own NavigationViews
                    } else {
                        SignInView()
                    }
                }
            }
            .onAppear {
                _ = Auth.auth().addStateDidChangeListener { _, user in
                    isUserLoggedIn = (user != nil)
                }
            }
        }
    }
    
    // Optionally, you can remove the setupFirebase() function if it's not used.
}
