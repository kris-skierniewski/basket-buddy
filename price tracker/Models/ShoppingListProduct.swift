//
//  ShoppingListProduct.swift
//  price tracker
//
//  Created by Kris Skierniewski on 08/09/2025.
//

struct ShoppingListProduct: DiffableItem {
    
    let productWithPrices: ProductWithPrices
    var isChecked: Bool = false
    
    init(productWithPrices: ProductWithPrices, isChecked: Bool) {
        self.productWithPrices = productWithPrices
        self.isChecked = isChecked
    }
    
    var diffIdentifier: String {
        return productWithPrices.product.id
    }
    
}
