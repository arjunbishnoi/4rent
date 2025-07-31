//
//  _rentApp.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-07.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct _rentApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var appVM = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appVM)
        }
    }
}
