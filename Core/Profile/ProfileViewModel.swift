//
//  ProfileViewModel.swift
//  Gralometer
//
//  Created by Marcus Benoit on 07.10.24.
//

import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    @Published var profilePicture: UIImage?
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func toggleGralStatus() {
        guard let user else { return }
        let currentValue = user.hasGral ?? false
        
        Task {
            try await UserManager.shared.updateGralStatus(userId: user.userId, hasGral: !currentValue)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}
