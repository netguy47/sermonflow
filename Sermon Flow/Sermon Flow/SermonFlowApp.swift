// 
//  SermonFlowApp.swift
//  Sermon Flow
//
//  CRITICAL: Remember to add the firebase-ios-sdk via the Xcode Swift Package Manager.
//  Link: https://github.com/firebase/firebase-ios-sdk
//

import SwiftUI
import FirebaseCore

@main
struct SermonFlowApp: App {
    // Firebase initialization
    init() {
        FirebaseApp.configure()
        
        // Request notification permissions
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
