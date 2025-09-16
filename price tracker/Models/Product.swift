//
//  Product.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2024.
//

import Foundation


struct Product: Identifiable, Codable, Equatable, DiffableItem {
    
    let id: String
    
    var name: String
    
    var description: String
    
    var category: ProductCategory
    
    var authorUid: String
    
    var diffIdentifier: String {
        return id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case authorUid
    }
    
    init(id: String, name: String, description: String, categoriser: ProductCategoriser = ProductCategoriser(), authorUid: String) {
        self.id = id
        self.name = name
        self.description = description
        self.category = categoriser.categorise(itemName: name)
        self.authorUid = authorUid
    }
    
    //custom decoder to handle previously optional ProductCategory
    init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          
          self.id = try container.decode(String.self, forKey: .id)
          self.name = try container.decode(String.self, forKey: .name)
          self.description = try container.decode(String.self, forKey: .description)
          
          self.category = try container.decodeIfPresent(ProductCategory.self, forKey: .category) ?? ProductCategoriser().categorise(itemName: name)
        self.authorUid = try container.decode(String.self, forKey: .authorUid)
      }
    
    //helper for tests
    init(id: String, name: String, description: String, category: ProductCategory, authorUid: String) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.authorUid = authorUid
    }
    
}
