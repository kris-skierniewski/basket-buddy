//
//  EnrichedShoppigList.swift
//  price tracker
//
//  Created by Kris Skierniewski on 08/09/2025.
//

struct EnrichedShoppingList: Identifiable {
    
    let id: String
    
    var products: [ShoppingListProduct] = []
    
    init() {
        id = UUID().uuidString
        products = []
    }
    
    init(id: String, products: [ShoppingListProduct]) {
        self.id = id
        self.products = products
    }
    
    var repoShoppingList: ShoppingList {
        let shoppingListItems = products.map({
            return ShoppingListItem(productId: $0.productWithPrices.product.id, isChecked: $0.isChecked)
        })
        return ShoppingList(id: id, products: shoppingListItems)
    }
    
    func isProductInList(_ productId: String) -> Bool {
        return products.contains(where: { $0.productWithPrices.product.id == productId })
    }
}
