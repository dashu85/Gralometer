//
//  SettingsView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 17.09.24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showSignInView: Bool
    @State private var showingChangePasswordSheet: Bool = false
    @State private var showingChangeEmailSheet: Bool = false
    @State private var newEmail: String = ""
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        VStack {
            List {
                if viewModel.authProviders.contains(.email) {
                    emailSection
                }
                
//                if !viewModel.authProviders.isEmpty {
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
//                }
                
                if viewModel.authUser?.isAnonymous == true {
                    VStack {
                        anonymousSection
                    }
                }
                
                Section {
                    Button("Konto löschen", role: .destructive) {
                        Task {
                            do {
                                try await viewModel.deleteAccount()
                                showSignInView = true
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadAuthProviders()
                viewModel.loadAuthUser()
            }
            .sheet(isPresented: $showingChangeEmailSheet) {
                ZStack {
                    Color.black
                    
                    VStack {
                        Text("Deine Emailadresse zurücksetzen. Danach wirst du ausgeloggt!")
                            .foregroundStyle(.yellow)
                        
                        TextField("Neue Emailadresse", text: $newEmail)
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.gray.opacity(0.4))
                            .cornerRadius(10)
                            .padding()

                        Button("Neue Email bestätigen") {
                            Task {
                                do {
                                    try await viewModel.updateEmail(newEmail: newEmail)
                                    showSignInView = true
                                } catch {
                                    print(error)
                                }
                                showingChangeEmailSheet = false
                                showSignInView = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.yellow)
                        .foregroundColor(.black)
                        .controlSize(.large)
                        .padding(.horizontal)
                        .presentationDetents([.medium, .large])
                        
                        Spacer()
                            .frame(height: 200)
                    }
                }
                .ignoresSafeArea()
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
                showingChangeEmailSheet = true
            }
            
            Button("Passwort ändern") {
                showingChangePasswordSheet = true
            }
            .actionSheet(isPresented: $showingChangePasswordSheet) {  // Attach the actionSheet modifier to the button
                // Define the content of the action sheet
                ActionSheet(title: Text("Passwort zurücksetzen. Junge, junge, junge..."),
                            message: Text("Der Link wird dann wohl an deine Email geschickt und du wirst ausgeloggt!"),
                            buttons: [
                                .destructive(Text("Passwort zurücksetzen"), action: {
                                    Task {
                                        do {
                                            try await viewModel.resetPassword()
                                            showSignInView = true
                                        } catch {
                                            print(error)
                                        }
                                        showingChangePasswordSheet = false
                                    }
                                }),
                                .cancel()
                            ])
            }
        } header: {
            Text("Email und Passwort")
        }
    }
    
    private var anonymousSection: some View {
        Section {
            Button("Mit Google einloggen") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("Google Account linked")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Mit Apple einloggen") {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("Apple Account linked")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Mit Email einloggen") {
                Task {
                    do {
                        try await viewModel.linkEmailAccount()
                        print("Email Account linked")
                    } catch {
                        print(error)
                    }
                }
            }
            
        } header: {
            Text("Account erstellen")
        }
    }
}
