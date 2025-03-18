//
//  NutriSnap2App.swift
//  NutriSnap2
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

// MARK: - Firebase Initialization (App Delegate)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("???? Firebase is configuring...") // Debug Log
        FirebaseApp.configure()
        print("Firebase configured successfully") //  Debug Log
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
            NavigationView {
                if showSplash {
                    SplashScreenView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSplash = false
                            }
                        }
                } else {
                    if isUserLoggedIn {
                        DashboardView()  // Show Dashboard if logged in
                    } else {
                        SignInView()  // Show Sign In screen if not logged in
                    }
                }
            }
            .onAppear {
                Auth.auth().addStateDidChangeListener { _, user in
                    isUserLoggedIn = (user != nil)
                }
            }
        }
    }

    // Ensure Firebase is set up correctly
    private func setupFirebase() {
        if FirebaseApp.app() == nil {
            print("⚠️ FirebaseApp is not configured, configuring now...")
            FirebaseApp.configure()
        } else {
            print("✅ FirebaseApp is already configured.")
        }
    }
}
