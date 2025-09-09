//
//  ShoppingList.swift
//  price tracker
//
//  Created by Kris Skierniewski on 12/11/2024.
//

import Foundation

struct ShoppingListItem: Codable {
    let productId: String
    var isChecked: Bool
}

struct ShoppingList: Identifiable, Codable {
    
    let id: String
    
    var products: [ShoppingListItem] = []
    
    init() {
        id = UUID().uuidString
        products = []
    }
    
    init(id: String, products: [ShoppingListItem]) {
        self.id = id
        self.products = products
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.products = try container.decodeIfPresent([ShoppingListItem].self, forKey: .products) ?? []
    }
    
}
