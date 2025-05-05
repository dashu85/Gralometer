//
//  StorageManager.swift
//  Gralometer
//
//  Created by Marcus Benoit on 01.05.25.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    private init() { }
    
    private let storage = Storage.storage().reference()
    
    private var images: StorageReference {
        storage.child("images")
    }
    
    private func userReference(userId: String) -> StorageReference {
        storage.child("users").child(userId).child("profileImages")
    }

    func getData(userId: String, path: String) async throws -> Data {
        try await storage.child(path).data(maxSize: 3 * 1024 * 1024)
    }
    
    func getProfileImage(userId: String, path: String) async throws -> UIImage {
        let data = try await getData(userId: userId, path: path)
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        
        return image
    }
    
    func getURLForImage(path: String) async throws -> URL {
        try await Storage.storage().reference(withPath: path).downloadURL()
    }
    
    // save profile image as data to firebase and create a reference to the storage bucket
    func saveProfileImage(data: Data, userId: String) async throws -> (path: String, name: String) {
            let meta = StorageMetadata()
            meta.contentType = "image/jpeg"

            let path = "\(UUID().uuidString).jpeg"

            let returnedMetaData = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: meta)

            guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
                throw URLError(.badServerResponse)
            }

            return (returnedPath, returnedName)
        }
    
    // save UIImage to Firebase
    func saveProfileImage(image: UIImage, userId: String) async throws -> (path: String, name: String) {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.badServerResponse) // TODO: Add appropriate error here
        }
        
        return try await saveProfileImage(data: data, userId: userId)
    }
}
