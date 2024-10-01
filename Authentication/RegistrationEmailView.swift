//
//  RegistrationInEmailView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 23.09.24.
//

import SwiftUI

struct RegistrationEmailView: View {
    @StateObject private var viewModel = RegistrationWithEmailViewModel()
    
    @Binding var showSignInView: Bool
    
    @State private var registrationFormComplete: Bool = false
        
    var body: some View {
        ZStack {
            Color.yellow
            
            VStack {
                if registrationFormComplete {
                    Text("Please enter your name, email and password.")
                        .font(.headline)
                        .foregroundStyle(.red)
                }

                TextField("Name...", text: $viewModel.displayName)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                TextField("Email...", text: $viewModel.email)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                SecureField("Passwort...", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                Button("Registrieren") {
                    Task {
                        do {
                            try await viewModel.signUp()
                            showSignInView = false
                            return
                        } catch {
                            registrationFormComplete.toggle()
                            print(error)
                        }
                    }
                }
                .font(.headline)
                .foregroundStyle(.yellow)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(!viewModel.email.isEmpty && !viewModel.password.isEmpty && !viewModel.displayName.isEmpty ? .black : .gray)
                .cornerRadius(10)
            }
            .navigationTitle("Email-Registrierung")
            .padding()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        RegistrationEmailView(showSignInView: .constant(false))
    }
}
