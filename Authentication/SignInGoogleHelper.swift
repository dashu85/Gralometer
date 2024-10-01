//
//  SignInGoogleHelper.swift
//  Gralometer
//
//  Created by Marcus Benoit on 28.09.24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}

@MainActor
final class SignInGoogleHelper {
    func signIn() async throws -> GoogleSignInResultModel {
        // find the top ViewController
        guard let topVC = Utilities.shared.topViewController() else { throw AuthenticationError.noTopViewController }

        // show the SignInWithGoogle Screen on top of the topVC
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        // retrieve the id and access token
        guard let idToken = gidSignInResult.user.idToken?.tokenString else { throw AuthenticationError.noIdTokenFound }
        let accessToken = gidSignInResult.user.accessToken.tokenString

        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        return tokens
    }
}
