//
//  ContentView.swift
//  notes
//
//  Created by Caleb Chiang on 2026-02-16.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var auth = AuthViewModel()
    
    var body: some View {
        Group {
            if auth.isLoggedIn {
                HomeView()
                    .environmentObject(auth)
            } else {
                AuthView()
                    .environmentObject(auth)
            }
        }
    }
}

#Preview {
    ContentView()
}
