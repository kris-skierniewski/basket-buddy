//
//  GenerableProductCategory.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/09/2025.
//

import FoundationModels

@available(iOS 26.0, *)
@Generable(description: "a category of a grocery product")
enum GenerableProductCategory: String, CaseIterable, Codable {
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
}
