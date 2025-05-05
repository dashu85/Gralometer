//
//  ProfileViewModel.swift
//  Gralometer
//
//  Created by Marcus Benoit on 07.10.24.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    
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
    
    func saveProfilePicture(item: PhotosPickerItem) {
        guard let user else { return }
        
        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let (path, name) = try await StorageManager.shared.saveProfileImage(data: data, userId: user.userId)
            print("SUCCESS")
            print(path)
            print(name)
            
            try await UserManager.shared.updateUserProfileImage(userId: user.userId, path: path)
        }
    }
}
