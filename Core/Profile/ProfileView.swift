//
//  ProvileView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 07.10.24.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var colorSchemeManager: ColorSchemeManager
    @Binding var showSignInView: Bool
    // Add a loading state
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            LinearGradient(colors: colorSchemeManager.selectedScheme.viewBackgroundGradient, startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Vereinsfarben:")
                    
                    Spacer()
                    
                    Picker("Color Scheme", selection: $colorSchemeManager.selectedScheme) {
                        
                        
                        ForEach(AppColorScheme.allCases) { scheme in
                            Text(scheme.description).tag(scheme)
                                .foregroundColor(colorSchemeManager.selectedScheme.textColor)
                        }
                    }
                }
                .pickerStyle(.menu) // You can choose another style if desired
                .padding()
                
                if let user = viewModel.user {
                    Text("User id: \(user.userId)")
                    
                    if let isAnonymous = viewModel.user?.isAnonymous {
                        Text("Anonymous: \(isAnonymous.description.capitalized)")
                    }
                    
                    Button  {
                        viewModel.toggleGralStatus()
                    } label: {
                        Text("Gralinhaber: \(user.hasGral ?? true)")
                    }
                }
                
                Spacer()
            }
            .onAppear {
                Task {
                    try? await viewModel.loadCurrentUser()
                    isLoading = false
                }
            }
            .navigationTitle("Profil")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView(showSignInView: $showSignInView)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            
            //            if isLoading {
            //                // Show a loading indicator while fetching the user
            //                ProgressView("Loading user data...")
            //                    .onAppear {
            //                        // Fetch user data when the view appears
            //                        Task {
            //                            try? await viewModel.loadCurrentUser()
            //                            // Once data is loaded, stop showing the loading indicator
            //                            isLoading = false
            //                        }
            //                    }
            //            }
        } // ZStack
    } // body
} // ProfileView

#Preview {
    let colorSchemeManagerPreview = ColorSchemeManager()
    
    ProfileView(showSignInView: .constant(false))
        .environment(colorSchemeManagerPreview)
}
