//
//  SettingsViewModel.swift
//  Gralometer
//
//  Created by Marcus Benoit on 29.09.24.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders () {
            authProviders = providers
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
        
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.deleteUser()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let userEmail = authUser.email else {
            throw AuthenticationError.emailNotFound
        }
        
        try await AuthenticationManager.shared.resetPassword(email: userEmail)
    }
    
    func updateEmail(newEmail email: String) async throws {
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    // update password to new password -> used resetPassword instead!
    func updatePassword(_ password: String) async throws {
        let password = "1234567890"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func linkGoogleAccount() async throws {
        let helper = await SignInGoogleHelper()
        let tokens = try await helper.signIn()
        self.authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
    }
    
    func linkAppleAccount() async throws {
        let helper = await SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        self.authUser = try await AuthenticationManager.shared.linkApple(tokens: tokens)
    }
    
    func linkEmailAccount() async throws {
        let email = "hello@testing.com"
        let password = "password"
        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
    }
}
