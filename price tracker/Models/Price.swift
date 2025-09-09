//
//  Price.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2024.
//

import Foundation

enum Unit: String, Codable, CaseIterable, Equatable {
    case grams = "g"
    case millilitres = "ml"
    case units = "Units"
}

struct Price: Identifiable, Codable, Equatable {
    
    let id: String
    
    let timestamp: Double
    
    let price: Double
    
    let quantity: Double
    let unit: Unit
    
    let shopId: String
    
    let productId: String
    
    let notes: String?
    
    init(productId: String, price: Double, shopId: String, unit: Unit, quantity: Double, notes: String) {
        self.id = UUID().uuidString
        self.price = price
        self.shopId = shopId
        self.timestamp = Date().timeIntervalSince1970
        self.unit = unit
        self.quantity = quantity
        self.notes = notes
        self.productId = productId
    }
    
    init(id: String, productId: String, price: Double, shopId: String, timestamp: Double, unit: Unit, quantity: Double, notes: String) {
        self.id = id
        self.productId = productId
        self.price = price
        self.timestamp = timestamp
        self.shopId = shopId
        self.unit = unit
        self.quantity = quantity
        self.notes = notes
    }
    
    init?(fromDictionary dictionary: [String: Any]) {
        
        let unitString = dictionary["unit"] as? String ?? Unit.units.rawValue
        let quantity = dictionary["quantity"] as? Double ?? 1
        let notes = dictionary["notes"] as? String ?? ""
        
        if let id = dictionary["id"] as? String,
           let price = dictionary["price"] as? Double,
           let shopId = dictionary["shopId"] as? String,
           let timeStamp = dictionary["timestamp"] as? Double,
           let unit = Unit(rawValue: unitString) {
            
            self.id = id
            self.price = price
            self.shopId = shopId
            self.timestamp = timeStamp
            
            self.notes = notes
            self.unit = unit
            self.quantity = quantity
            
        } else {
            return nil
        }
        productId = "" //TODO: remove
    }
    
    var dictionaryValue: Any {
        return [
            "id": id,
            "timestamp": timestamp,
            "price": price,
            "shopId": shopId,
            "unit": unit.rawValue,
            "quantity": quantity,
            "notes":notes ?? ""
        
        ]
    }
    
    func priceString(currency: Currency) -> String {
        return String(format: "\(currency.symbol)%.2f", price)
    }
    
    func quantityAndUnitString() -> String {
        if unit == .grams {
            return "\(Int(quantity))g"
        } else if unit == .millilitres {
            return "\(Int(quantity))ml"
        } else {
            if quantity == 1.0 {
                return "\(Int(quantity)) unit"
            }
            return "\(Int(quantity)) units"
        }
    }
    
    func perUnitPrice() -> Double {
        if unit == .grams || unit == .millilitres {
            return (price/quantity) * 100
        } else {
            return price/quantity
        }
    }
    
    
    func perUnitPriceString(currency: Currency) -> String {
        let oneUnitString: String
        if unit == .grams {
            oneUnitString = "/100g"
        } else if unit == .millilitres {
            oneUnitString = "/100ml"
        } else {
            oneUnitString = " each"
        }
        let priceString = String(format: "\(currency.symbol)%.2f", perUnitPrice())
        
        return "\(priceString)\(oneUnitString)"
        
    }
}
