//
//  TabBarView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 22.10.24.
//


import SwiftUI

struct TabBarView: View {
    @EnvironmentObject private var colorSchemeManager: ColorSchemeManager
    @Binding var showSignInView: Bool
    
    enum Tab {
        case myChallenges, allChallenges, profile
    }
    
    @State private var selectedTab: Tab = .profile
    
    // to upload json
    @StateObject private var viewModel = ChallengesViewModel()
    
    @Binding var path: NavigationPath
    
    var body: some View {
        TabView(selection: tabSelection()) {
            NavigationStack {
                MyChallengesView()
            }
                .tabItem {
                    Image(systemName: "figure.dance")
                    Text("My Challenges")
                }
                .tag(Tab.myChallenges)
            
            
            ChallengesView(showSignInView: $showSignInView, path: $path)
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Challenges")
                }
                .tag(Tab.allChallenges)
            
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
            .tag(Tab.profile)
        }
    }
}

extension TabBarView {
    private func tabSelection() -> Binding<Tab> {
        // get Block
        Binding {
            self.selectedTab
        } set: { tappedTab in
            if tappedTab == self.selectedTab {
                // User tapped on current active tab icon => pop to root / Scroll to top
            }
            
            self.selectedTab = tappedTab
        }
    }
}

#Preview {
    let colorSchemeManagerPreview = ColorSchemeManager()
    
    NavigationStack {
        TabBarView(showSignInView: .constant(false), path: .constant(NavigationPath()))
            .environment(colorSchemeManagerPreview)
    }
}
