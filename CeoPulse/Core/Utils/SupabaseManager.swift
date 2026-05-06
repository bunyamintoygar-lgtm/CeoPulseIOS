import Foundation
import Supabase
import SwiftUI
import Combine

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://wvsbpsahpshgmrgcxpmq.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2c2Jwc2FocHNoZ21yZ2N4cG1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMDE0ODksImV4cCI6MjA5MzU3NzQ4OX0.gNav-OBp2gvNSluMIG837O-fTNy5I3S5RsjGJkHDMYU"
        )
    }
}
