//
//  SettingsViewModel.swift
//  Gralometer
//
//  Created by Marcus Benoit on 29.09.24.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders () {
            authProviders = providers
        }
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let userEmail = authUser.email else {
            throw AuthenticationError.emailNotFound
        }
        
        try await AuthenticationManager.shared.resetPassword(email: userEmail)
    }
    
    // TODO: update email to new email -> fix using a sheet?
    func updateEmail(_ email: String) async throws {
        let email1 = "hello@world.com"
        try await AuthenticationManager.shared.updateEmail(email: email1)
    }
    
    // TODO: update password to new password -> fix using a sheet?
    func updatePassword(_ password: String) async throws {
        let password = "password"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
}
