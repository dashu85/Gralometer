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
        
    var body: some View {
        ZStack {
            Color.yellow
            
            VStack {
                
                TextField("Name...", text: $viewModel.displayName)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                // Validation message
                if !viewModel.isEmailValid && viewModel.submitAttempted {
                    Text("Please enter a valid email address")
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
                
                TextField("Email...", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                    .onChange(of: viewModel.email) { oldValue, newValue in
                        viewModel.validateEmail(newValue)
                    }
                
                if viewModel.password.count <= 6  && viewModel.submitAttempted {
                    Text("Your password has to be at least 6 characters long.")
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
                
                SecureField("Passwort...", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                Button("Registrieren") {
                    viewModel.validateEmail(viewModel.email)
                    viewModel.submitAttempted = true
                    
                    Task {
                        do {
                            try await viewModel.signUp()
                            showSignInView = false
                            return
                        } catch {
                            viewModel.registrationNameCompleted = false
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
