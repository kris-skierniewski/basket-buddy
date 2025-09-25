//
//  DonationManager.swift
//  price tracker
//
//  Created by Kris Skierniewski on 25/09/2025.
//

class DonationManager {
    static var shared: DonationManager = DonationManager()
    
    private init() {
        
    }
    
    func donateAddToShoppingList(itemName: String) {
        let shoppingItem = ShoppingItem(id: itemName, name: itemName)
        
        let intent = AddToShoppingListIntent()
        intent.item = shoppingItem
        
        // Donate the intent
        Task {
            try? await intent.donate()
        }
    }
}
