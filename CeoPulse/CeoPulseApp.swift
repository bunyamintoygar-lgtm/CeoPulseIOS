//
//  CeoPulseApp.swift
//  CeoPulse
//
//  Created by bunyamin toygar on 6.05.2026.
//

import SwiftUI

@main
struct CeoPulseApp: App {
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            if supabaseManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
                    .environmentObject(supabaseManager)
                    .onOpenURL { url in
                        // Handle Supabase Auth Redirects if needed
                    }
            }
        }
    }
}
