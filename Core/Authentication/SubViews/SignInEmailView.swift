//
//  SignInEmailView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 16.09.24.
//

import SwiftUI

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInWithEmailViewModel()
    
    @Binding var showSignInView: Bool
    
    @State private var showingResetPasswordView: Bool = false
    @State private var signInViewFormCompleted: Bool = false
    @State private var resetPasswordForEmail: String = ""
    
    var body: some View {
        ZStack {
            Color.yellow
            
            VStack {
                
                if signInViewFormCompleted {
                    Text("Please correct your email / password.")
                        .font(.headline)
                        .foregroundStyle(.red)
                }
                
                TextField("Email...", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                SecureField("Passwort...", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                Button("Anmelden") {
                    Task {
                        do {
                            try await viewModel.signIn()
                            showSignInView = false
                            return
                        } catch {
                            viewModel.password = ""
                            signInViewFormCompleted = true
                            print(error)
                        }
                    }
                }
                .font(.headline)
                .foregroundStyle(.yellow)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(!viewModel.email.isEmpty && !viewModel.password.isEmpty ? .black : .gray)
                .cornerRadius(10)
                
                Spacer()
                    .frame(height: 25)
                
                Button("Passwort zurücksetzen") {
                    resetPasswordForEmail = viewModel.email
                    showingResetPasswordView.toggle()
                }
            }
            .navigationTitle("Email-Anmeldung")
            .padding()
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingResetPasswordView) {
            ZStack {
                Color.black
                
                VStack {
                    TextField("Email...", text: $resetPasswordForEmail)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(10)
                        .padding()

                    Button("Passwort zurücksetzen") {
                        Task {
                            do {
                                try await viewModel.resetPassword(email: resetPasswordForEmail)
                                showSignInView = true
                            } catch {
                                print(error)
                            }
                            showingResetPasswordView = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.yellow)
                    .foregroundColor(.black)
                    .controlSize(.large)
                    .padding(.horizontal)
                    .presentationDetents([.medium, .large])
                    
                    Spacer()
                        .frame(height: 200)
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack {
        SignInEmailView(showSignInView: .constant(false))
    }
}
