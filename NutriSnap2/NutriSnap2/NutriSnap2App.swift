//
//  NutriSnap2App.swift
//  NutriSnap2
//
//  Created by Tech on 2025-03-14.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct NutriSnap2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isUserLoggedIn: Bool = Auth.auth().currentUser != nil
    @State private var showSplash = true  // Controls splash screen visibility

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
}
