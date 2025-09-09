//
//  ProductCategoriser.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2025.
//

class ProductCategoriser {
    private let keywords: [ProductCategory: [String]] = [
        .frozen: ["frozen", "freezer", "ice"],
        .canned: ["canned", "tinned", "jar", "sauce", "baked beans", "sweet corn"],
        .meat: ["chicken", "beef", "pork", "lamb", "turkey"],
        .fish: ["fish", "tuna", "cod", "haddock"],
        .grains: ["pasta", "rice", "cous"],
        .dairy: ["milk", "cheese", "butter", "yogurt", "cream"],
        .household: ["toilet", "soap", "detergent", "shampoo"],
        .bakery: ["bread", "bagel", "bun", "croissant", "cake", "roll", "baguette"],
        .produce: ["apple", "banana", "carrot", "potato", "onion", "lettuce", "tomato", "cabbage"],
        .drinks: ["water", "lemonade", "soda", "cola", "juice", "wine", "beer", "coke"]
    ]
    
    func categorise(itemName: String) -> ProductCategory {
        let lowercased = itemName.lowercased()
        
        for (category, words) in keywords {
            if words.contains(where: { lowercased.contains($0) }) {
                return category
            }
        }
        
        return .other
    }
}

