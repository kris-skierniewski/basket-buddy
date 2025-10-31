//
//  ShoppingListProduct.swift
//  price tracker
//
//  Created by Kris Skierniewski on 08/09/2025.
//

struct ShoppingListProduct: DiffableItem {
    
    let productWithPrices: ProductWithPrices
    var isChecked: Bool = false
    var quantity: Double?
    var unit: Unit?
    
    init(productWithPrices: ProductWithPrices, isChecked: Bool, quantity: Double?, unit: Unit?) {
        self.productWithPrices = productWithPrices
        self.isChecked = isChecked
        self.quantity = quantity
        self.unit = unit
    }
    
    var diffIdentifier: String {
        return productWithPrices.product.id
    }
    
    var quantityString: String {
        if let quantity = quantity, let unit = unit {
            if unit == .grams {
                return "\(Int(quantity))g"
            } else if unit == .millilitres {
                return "\(Int(quantity))ml"
            } else {
                if quantity == 1.0 {
                    return ""
                }
                return "x\(Int(quantity))"
            }
        } else {
            return ""
        }
    }
    
}
