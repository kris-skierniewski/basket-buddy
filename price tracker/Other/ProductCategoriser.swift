//
//  ProductCategoriser.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2025.
//

import Foundation
import FoundationModels

class ProductCategoriser {
    
    static let shared = ProductCategoriser()
    
    private var classificationTask: Task<Void, Never>?
    
    private init() {
        
    }
    
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
    
    func generateAICategory(name: String, description: String, completion: @escaping @MainActor (ProductCategory) -> Void) {
        classificationTask?.cancel()
        classificationTask = Task { [weak self] in
            
            let debounceDelay: TimeInterval = 0.5
            try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            let category = await self?.performClassification(name: name, description: description)
            await completion(category ?? .other)
        }
    }
    
    @MainActor
    private func performClassification(name: String, description: String) async -> ProductCategory {
        if #available(iOS 26.0, *) {
            
            guard !name.isEmpty else { return .other }
            guard SystemLanguageModel.default.isAvailable else { return .other }
            let session = LanguageModelSession()
            let prompt = """
                You are classifying grocery items into standard supermarket categories
                to make them easier to find. Return the one category that is most fitting for item with name: \(name), and description: \(description).
                """
            do {
                let response = try await session.respond(to: prompt, generating: GenerableProductCategory.self)
                let generableCategory = response.content
                if let productCategory = ProductCategory(rawValue: generableCategory.rawValue) {
                    return productCategory
                } else {
                    return categorise(itemName: name)
                }
            } catch {
                return categorise(itemName: name)
            }
        } else {
            return categorise(itemName: name)
        }
    }
}

