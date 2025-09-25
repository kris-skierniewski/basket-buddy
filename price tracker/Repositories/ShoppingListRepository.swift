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
    func getShoppingList() async throws -> ShoppingList?
}

class FirebaseShoppingListRepository: ShoppingListRepository {
    
    private let firebaseService: FirebaseDatabaseService
    private let datasetId: String
    
    init(firebaseService: FirebaseDatabaseService, datasetId: String) {
        self.firebaseService = firebaseService
        self.datasetId = datasetId
    }
    
    func updateShoppingList(_ shoppingList: ShoppingList, completion: @escaping (Result<Void, any Error>) -> Void) {
        let path = "datasets/\(datasetId)/shoppingList"
        firebaseService.update(shoppingList, at: path, completion: completion)
    }
    
    func deleteShoppingList( completion: @escaping (Result<Void, any Error>) -> Void) {
        let path = "datasets/\(datasetId)/shoppingList"
        firebaseService.delete(at: path, completion: completion)
    }
    
    func observeShoppingList(onChange: @escaping (ShoppingList?) -> Void) -> any ObserverHandle {
        let path = "datasets/\(datasetId)/shoppingList"
        return firebaseService.observe(path, as: ShoppingList.self, onChange: onChange)
    }
    
    func getShoppingList() async throws -> ShoppingList? {
        let path = "datasets/\(datasetId)/shoppingList"
        return try await withCheckedThrowingContinuation { continuation in
            firebaseService.getValue(path, as: ShoppingList.self) { result in
                switch result {
                case .success(let shoppingList):
                    continuation.resume(returning: shoppingList)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
    }
    
}
