//
//  ProductCategory.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2025.
//

enum ProductCategory: String, CaseIterable, Codable {
    case meat
    case fish
    case canned
    case dairy
    case bakery
    case grains
    case produce
    case drinks
    case frozen
    case household
    case other
    
    var iconName: String {
        switch self {
        case .meat: return "meat"
        case .fish: return "fish"
        case .canned: return "canned"
        case .dairy: return "dairy"
        case .bakery: return "bakery"
        case .grains: return "grains"
        case .produce: return "produce"
        case .drinks: return "drinks"
        case .frozen: return "frozen"
        case .household: return "household"
        case .other: return "other"
        }
    }
}
