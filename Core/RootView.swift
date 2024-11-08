//
//  RootView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 24.10.24.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView: Bool = false
    @State private var path = NavigationPath()
    
    var body: some View {
        ZStack {
            if !showSignInView {
                TabBarView(showSignInView: $showSignInView, path: $path)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
