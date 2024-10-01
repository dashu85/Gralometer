//
//  SettingsView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 17.09.24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showSignInView: Bool
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        VStack {
            List {
                if viewModel.authProviders.contains(.email) {
                    emailSection
                }
                
                Button("Abmelden") {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadAuthProviders()
            }
        }
        .navigationTitle("Einstellungen")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button("Email ändern") {
                Task {
                    do {
                        try await viewModel.updateEmail("hello@world.com")
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Passwort ändern") {
                Task {
                    do {
                        try await viewModel.updatePassword("password")
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
            
            
        } header: {
            Text("Email und Passwort")
        }
    }
}
