//
//  SignInWithEmailViewModel.swift
//  Gralometer
//
//  Created by Marcus Benoit on 29.09.24.
//

import Foundation

@MainActor
final class SignInWithEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws  {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
        
        // discardable result - if it is created, everything is fine and works
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    
    func signIn() async throws  {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
        
        // discardable result - if it is created, everything is fine and works
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    func resetPassword(email: String) async throws {
//        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
//
//        guard let userEmail = authUser.email else {
//            throw AuthentificationError.emailNotFound
//        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
}
