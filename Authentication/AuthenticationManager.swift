//
//  AuthenticationManager.swift
//  Gralometer
//
//  Created by Marcus Benoit on 16.09.24.
//

import FirebaseAuth
import Foundation

struct AuthDataResultModel {
    let uid: String
    let displayName: String?
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.displayName = user.displayName
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() { }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotFound
        }
        
        return AuthDataResultModel(user: user)
    }
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        return providers
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotFound
        }
        
        try await user.delete()
    }
}

// MARK: SIGN IN WITH EMAIL
extension AuthenticationManager {
    @discardableResult // might or might not be used -> now it throws no warnings
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResults = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResults.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResults = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResults.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    // error: "This operation is sensitive and requires recent authentication. Log in again before retrying this request."
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotFound
        }
        
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.emailNotFound
        }
        
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}

// MARK: SIGN IN SSO
extension AuthenticationManager {
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: tokens.token, rawNonce: tokens.nonce)
        
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

// MARK: SIGN IN ANONYMOUSLY
extension AuthenticationManager {
    @discardableResult
    func signInAnonymous() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        return try await linkCredential(credential: credential)
    }
    
    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        
        return try await linkCredential(credential: credential)
    }
    
    func linkApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: tokens.token, rawNonce: tokens.nonce)
        
        return try await linkCredential(credential: credential)
    }
    
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotFound
        }
        
        let authDataResult = try await user.link(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
