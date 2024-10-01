//
//  AuthenticationView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 16.09.24.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @State private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        
        ZStack {
            Color.yellow
            VStack {
                Spacer()
                
                Image(systemName: "trophy")
                    .foregroundStyle(.black)
                    .font(.largeTitle)
                
                Text("Gralometer")
                    .foregroundStyle(.black)
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                VStack {
                    NavigationLink {
                        RegistrationEmailView(showSignInView: $showSignInView)
                    } label: {
                        Text("Registrieren")
                            .font(.headline)
                            .foregroundStyle(.black)
                    }
                    .padding()
                    
                    Divider()
                    
                    Button("Sign in with Google") {
                        Task {
                            do {
                                try await viewModel.signInWithGoogle()
                                showSignInView = false
                            } catch {
                                print("Error signing in: \(error)")
                            }
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(6)
                    .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.signInWithApple()
                                showSignInView = false
                            } catch {
                                print("Error signing in: \(error)")
                            }
                        }
                    }, label: {
                        signInWithAppleButtonViewRepresentable(type: .default, style: .black)
                            .allowsHitTesting(false)
                    })
                    .frame(height: 55)
                    .padding(.horizontal)
                    
                    
                    NavigationLink {
                        SignInEmailView(showSignInView: $showSignInView)
                    } label: {
                        Text("Mit Email einloggen")
                            .font(.title3.bold())
                            .foregroundStyle(.yellow)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(.black)
                            .cornerRadius(6)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 60)
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}
