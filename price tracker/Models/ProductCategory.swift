//
//  ProductCategory.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2025.
//
enum ProductCategory: String, CaseIterable, Codable {
    case meat
    case freshFish
    case tinsAndJars
    case dairy
    case bakery
    case grains
    case produce
    case herbsAndSpices
    case drinks
    case frozen
    case household
    case snacks
    case condiments
    case other
    
    var title: String {
        switch self {
        case .herbsAndSpices: return "Herbs & spices"
        case .tinsAndJars: return "Tins & Jars"
        case .freshFish: return "Fish"
        default: return rawValue.capitalized
        }
    }
    
    var iconName: String {
        switch self {
        case .meat: return "meat"
        case .freshFish: return "fish"
        case .tinsAndJars: return "canned"
        case .dairy: return "dairy"
        case .bakery: return "bakery"
        case .grains: return "grains"
        case .produce: return "produce"
        case .drinks: return "drinks"
        case .frozen: return "frozen"
        case .household: return "household"
        case .herbsAndSpices: return "herbsandspices"
        case .snacks: return "snacks"
        case .condiments: return "condiments"
        case .other: return "other"
        }
    }
}
