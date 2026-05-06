//
//  CeoPulseApp.swift
//  CeoPulse
//
//  Created by bunyamin toygar on 6.05.2026.
//

import SwiftUI

@main
struct CeoPulseApp: App {
    @State private var isAuthenticated = false
    
    init() {
        // Initialize Auth Listener if needed
    }
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                MainTabView()
            } else {
                LoginView()
                    .onOpenURL { url in
                        // Handle Supabase Auth Redirects if needed
                    }
            }
        }
    }
}
