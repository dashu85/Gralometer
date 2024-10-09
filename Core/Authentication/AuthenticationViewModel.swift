//
//  AuthenticationViewModel.swift
//  Gralometer
//
//  Created by Marcus Benoit on 29.09.24.
//

import AuthenticationServices
import FirebaseAuth
import Foundation
import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {

    func signInWithGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
    
    func signInWithApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
    }
    
    func signInAnonymously() async throws {
        try await AuthenticationManager.shared.signInAnonymous()
    }
}




