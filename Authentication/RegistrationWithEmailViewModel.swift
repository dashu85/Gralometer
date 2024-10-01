//
//  RegistrationWithEmailViewModel.swift
//  Gralometer
//
//  Created by Marcus Benoit on 29.09.24.
//

import Foundation

@MainActor
final class RegistrationWithEmailViewModel: ObservableObject {
    @Published var displayName = ""
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
}
