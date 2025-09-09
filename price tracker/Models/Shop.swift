//
//  Shop.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2024.
//

import Foundation

struct Shop: Identifiable, Codable, Equatable, Comparable {
    
    let id: String
    
    var name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
    }
    
    init?(fromDictionary dictionary: [String: Any]) {
        if let id = dictionary["id"] as? String,
           let name = dictionary["name"] as? String {
            self.id = id
            self.name = name
        } else {
            return nil
        }
    }
    var dictionaryValue: Any {
        return [
            "id": id,
            "name": name
        ]
    }
    
    static func < (lhs: Shop, rhs: Shop) -> Bool {
        return lhs.name < rhs.name
    }
}
