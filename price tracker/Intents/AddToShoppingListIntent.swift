//
//  AddToShoppingListIntent.swift
//  price tracker
//
//  Created by Kris Skierniewski on 24/09/2025.
//

import AppIntents
import Foundation

struct AddToShoppingListIntent: AppIntent {
    static var title: LocalizedStringResource = "Add to shopping list"
    static var description = IntentDescription("Add an item to your shopping list")
    
    @Parameter(title: "Item name",
               description: "The item to add to your shopping list")
    var item: ShoppingItem
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$item) to my shopping list")
    }
    
    func perform() async throws -> some ProvidesDialog {
        
        let authService = FirebaseAuthService()
        if let currentUserId = authService.currentUserId {
            let firebaseService = FirebaseDatabaseService()
            let datatsetRepository = FirebaseDatasetRepository(firebaseService: firebaseService, userId: currentUserId)
            
            do {
                
                guard let datasetId = try await datatsetRepository.getUserDatasetId() else {
                    return .result(dialog: "Sorry, you can't do this right now. Please finish setting up in the app.")
                }
                
                let combinedRepository = CombinedRepository(datasetId: datasetId, firebaseService: firebaseService)
                
                
                guard var shoppingList = try await combinedRepository.getShoppingList() else {
                    return .result(dialog: "I couldn't find a shopping list in Basket Buddy.")
                }
                
                let products = try await combinedRepository.getProducts()
                
                if let existingProduct = products.first(where: { $0.name.lowercased() == item.name.lowercased()}) {
                    guard !shoppingList.products.contains(where: { $0.productId == existingProduct.id }) else {
                        return .result(dialog: "\(item.name) is already in your shopping list.")
                    }
                    shoppingList.products.append(ShoppingListItem(productId: existingProduct.id, isChecked: false, quantity: nil, unit: nil))
                    try await combinedRepository.updateShoppingList(shoppingList)
                    
                    return .result(dialog: "\(item.name) was added to your shopping list in basket buddy")
                } else {
                    var newProduct = Product(id: UUID().uuidString, name: item.name, description: "", authorUid: currentUserId)
                    
                    try await combinedRepository.addProduct(product: newProduct)
                    
                    //categorise
                    Task {
                        ProductCategoriser.shared.generateAICategory(name: newProduct.name, description: "") { category in
                            newProduct.category = category
                            combinedRepository.updateProduct(newProduct) { _ in
                                
                            }
                        }
                    }
                    
                    
                    shoppingList.products.append(ShoppingListItem(productId: newProduct.id, isChecked: false, quantity: nil, unit: nil))
                    try await combinedRepository.updateShoppingList(shoppingList)
                    return .result(dialog: "\(item.name) was added to your shopping list in basket buddy")
                }
            } catch {
                return .result(dialog: "Sorry, something went wrong.")
            }
            
        } else {
            return .result(dialog: "Sorry, you need to be logged in to do this.")
        }
        
    }
    
}

struct ShoppingItem: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Shopping Item")
    static var defaultQuery = ShoppingItemQuery()
    
    var id: String
    var name: String
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

struct ShoppingItemQuery: EntityStringQuery {
    typealias Entity = ShoppingItem
    func entities(matching string: String) async throws -> [ShoppingItem] {
        return [ShoppingItem(id: string, name: string)]
    }
    
    func entities(for identifiers: [String]) async throws -> [ShoppingItem] {
        return identifiers.map { ShoppingItem(id: $0, name: $0) }
    }
}

struct ShoppingListAppShortcuts: AppShortcutsProvider {
    typealias ShoppingItem = String
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: AddToShoppingListIntent(),
                    phrases: [
                        "Add \(\.$item) to my shopping list using \(.applicationName)",
                        "Add \(\.$item) to my shopping list in \(.applicationName)",
                        "Add \(\.$item) to my shopping list with \(.applicationName)",
                        "Put \(\.$item) on my shopping list in \(.applicationName)",
                        "Add \(\.$item) to my grocery list in \(.applicationName)",
                        "In \(.applicationName), add \(\.$item) to my shopping list",
                        "With \(.applicationName), add \(\.$item) to my shopping list",
                        "Using \(.applicationName), add \(\.$item) to my shopping list",
                        "In \(.applicationName), add to my shopping list \(\.$item)"
                    ],
                    shortTitle: "Add to shopping list",
                    systemImageName: "cart.badge.plus")
    }
}

