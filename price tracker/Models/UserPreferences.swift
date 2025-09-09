//
//  UserPreferences.swift
//  price tracker
//
//  Created by Kris Skierniewski on 19/10/2024.
//

import Foundation

enum Currency: String, CaseIterable, Codable {
    case gbp
    case eur
    case usd
    
    var symbol: String {
        if self == .gbp {
            return "£"
        } else if self == .eur {
            return "€"
        } else {
            return "$"
        }
    }
}

struct UserPreferences: Codable {
    var currency: Currency
    
    init() {
        self.currency = .gbp //default
    }
    
}
