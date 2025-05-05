//
//  Errors.swift
//  Gralometer
//
//  Created by Marcus Benoit on 20.09.24.
//

import Foundation

import Foundation

enum AuthenticationError: Error {
    case emailNotFound
    case noPassword
    case userNotFound
    case noTopViewController
    case noIdTokenFound
    case unexpected(code: Int)
}

// For each error type return the appropriate description
extension AuthenticationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .emailNotFound:
            return "This user does not have an email address."
        case .noPassword:
            return "There is no password associated with this user."
        case .userNotFound:
            return "This user does not exist."
        case .noTopViewController:
            return "There is no top view controller."
        case .noIdTokenFound:
            return "There is no ID token."
        case .unexpected(_):
            return "An unexpected error occurred."
        }
    }
}

enum StorageError: Error {
    case dataNotFound
    case cannotConvertData
}

// For each error type return the appropriate description
extension StorageError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dataNotFound:
            return "No data was found."
        case .cannotConvertData:
            return "Image could not be converted to data."
        }
    }
}
