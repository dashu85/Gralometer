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
    @Published var isEmailValid: Bool = false
    @Published var registrationNameCompleted: Bool = false
    @Published var submitAttempted = false  // Tracks if the submit button was pressed
    
    func signUp() async throws  {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
        
        // discardable result - if it is created, everything is fine and works
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    // Email validation method using regex
    func validateEmail(_ email: String) {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isEmailValid = emailPredicate.evaluate(with: email)
        print("isEmailValid: \(isEmailValid)")
    }
}
