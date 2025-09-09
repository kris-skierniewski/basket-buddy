//
//  ShoppingListRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 05/09/2025.
//

protocol ShoppingListRepository {
    func updateShoppingList(_ shoppingList: ShoppingList, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteShoppingList(completion: @escaping (Result<Void, Error>) -> Void)
    func observeShoppingList(onChange: @escaping (ShoppingList?) -> Void) -> ObserverHandle
}

class FirebaseShoppingListRepository: ShoppingListRepository {
    
    private let firebaseService: FirebaseDatabaseService
    private let userPath: String
    
    init(firebaseService: FirebaseDatabaseService, userId: String) {
        self.firebaseService = firebaseService
        self.userPath = userId
    }
    
    func updateShoppingList(_ shoppingList: ShoppingList, completion: @escaping (Result<Void, any Error>) -> Void) {
        let path = "shoppingList/\(userPath)"
        firebaseService.update(shoppingList, at: path, completion: completion)
    }
    
    func deleteShoppingList( completion: @escaping (Result<Void, any Error>) -> Void) {
        let path = "shoppingList/\(userPath)"
        firebaseService.delete(at: path, completion: completion)
    }
    
    func observeShoppingList(onChange: @escaping (ShoppingList?) -> Void) -> any ObserverHandle {
        let path = "shoppingList/\(userPath)"
        return firebaseService.observe(path, as: ShoppingList.self, onChange: onChange)
    }
    
}
