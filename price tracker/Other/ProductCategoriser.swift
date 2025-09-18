//
//  ProductCategoriser.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2025.
//

class ProductCategoriser {
    private let keywords: [ProductCategory: [String]] = [
        .frozen: ["frozen", "freezer", "ice", "chips", "peas", "hash browns"],
        .tinsAndJars: ["canned", "tinned", "jar", "sauce", "baked beans", "sweet corn"],
        .meat: ["chicken", "beef", "pork", "lamb", "turkey", "ham", "gammon", "joint"],
        .freshFish: ["fish", "tuna", "cod", "haddock"],
        .grains: ["pasta", "rice", "cous"],
        .dairy: ["milk", "cheese", "butter", "yogurt", "cream", "mozzarella", "cheddar", "feta", "gouda", "parmesan"],
        .household: ["toilet", "soap", "detergent", "shampoo", "kitchen roll"],
        .bakery: ["bread", "bagel", "bun", "croissant", "cake", "roll", "baguette"],
        .produce: ["apple", "banana", "strawberr", "raspberr", "carrot", "parsnip", "potato", "onion", "lettuce", "tomato", "cabbage", "celery", "spniach", "broccoli", "cauliflower", "green bean", "pepper", "asparagus", "garlic"],
        .herbsAndSpices: ["dill", "basil", "corriander", "salt", "black pepper", "cayenne", "parsley", "thyme", "chive", "ginger", "mint", "masala", "tumeric", "paprika", "garlic powder", "cumin"],
        .drinks: ["water", "lemonade", "soda", "cola", "juice", "wine", "beer", "coke"],
        .snacks: ["crisps","biscuits", "chocolate"]
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

