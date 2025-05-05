//
//  ProvileView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 07.10.24.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var colorSchemeManager: ColorSchemeManager
    @Binding var showSignInView: Bool
    @State private var url: URL? = nil
    
    // Add a loading state
    @State private var isLoading = true
    @State private var selectedProfileImage: PhotosPickerItem? = nil
    
    var body: some View {
        ZStack {
            LinearGradient(colors: colorSchemeManager.selectedScheme.viewBackgroundGradient, startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack(alignment: .center) {
                VStack {
                    if let url {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 150, height:  150)
                                .foregroundStyle(.black)
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                    }
                    
                    PhotosPicker(selection: $selectedProfileImage, matching: .images) {
                        if selectedProfileImage == nil {
                            Text("Profilfoto hinzufügen")
                            
                        } else {
                            Text("Profilfoto ändern")
                        }
                    }
                }
                
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
//                    isLoading = false
                    
                    if let user = viewModel.user, let path = user.profileImagePath {
                        let url = try? await StorageManager.shared.getURLForImage(path: path)
                        self.url = url
                    }
                }
            }
            .onChange(of: selectedProfileImage) {
                if selectedProfileImage != nil {
                    viewModel.saveProfilePicture(item: selectedProfileImage!)
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
    @Previewable @State var path = NavigationPath()
    let colorSchemeManager = ColorSchemeManager()
    
    ProfileView(showSignInView: .constant(false))
        .environmentObject(colorSchemeManager)
}
