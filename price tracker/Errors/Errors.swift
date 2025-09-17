//
//  Errors.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

enum ProductValidationError: Error, Equatable, LocalizedError {
    case emptyName
    case emptyShopName
    case emptyPrice
    case emptyQuantity
    case emptyUnit
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Product name is empty."
        case .emptyShopName:
            return "Shop name is empty."
        case .emptyPrice:
            return "Price is empty."
        case .emptyQuantity:
            return "Quantity is empty."
        case .emptyUnit:
            return "Unit is empty"
        }
    }
}

enum RepositoryError: Error, Equatable, LocalizedError {
    case productNotFound
    case invalidIndex
    case shopNotFound
    case productAlreadyInShoppingList
    case cannotFetchDataset
    case notEncodable
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found."
        case .invalidIndex:
            return "Invalid index."
        case .shopNotFound:
            return "Shop not found."
        case .productAlreadyInShoppingList:
            return "Product already in shopping list."
        case .cannotFetchDataset:
            return "Your data cannot be fetched right now."
        case .notEncodable:
            return "Your data cannot be encoded."
        }
    }
}

enum InviteError: Error, Equatable, LocalizedError {
    case inviteNotFound
    case inviteExpired
    case inviteCodeEmpty
    
    var errorDescription: String? {
        switch self {
        case .inviteExpired:
            return "Invite expired."
        case .inviteNotFound:
            return "Invite not found."
        case .inviteCodeEmpty:
            return "Invite code is empty."
        }
    }
}

enum AuthenticationError: Error, Equatable, LocalizedError {
    case unknownError
    case notSignedIn
    case emptyEmailAddress
    case emptyPassword
    case passwordsDontMatch
    case displayNameEmpty
    
    var errorDescription: String? {
        switch self {
        case .unknownError:
            return "An unknown error occurred."
        case .notSignedIn:
            return "You are not signed in."
        case .emptyEmailAddress:
            return "Email address is empty."
        case .emptyPassword:
            return "Password is empty."
        case .passwordsDontMatch:
            return "Passwords do not match"
        case .displayNameEmpty:
            return "Display name is empty"
        }
    }
    
}
