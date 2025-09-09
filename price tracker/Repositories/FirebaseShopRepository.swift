//
//  FirebaseShopRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 02/09/2025.
//

protocol ShopRepository {
    func addShop(_ shop: Shop, completion: @escaping (Result<Void, Error>) -> Void)
    func observeShops(onChange: @escaping ([Shop]) -> Void) -> ObserverHandle
    func deleteAllShops(completion: @escaping (Result<Void, Error>) -> Void)
}

class FirebaseShopRepository: ShopRepository {
    private let firebaseService: FirebaseDatabaseService
    private let userPath: String
    
    init(firebaseService: FirebaseDatabaseService, userId: String) {
        self.firebaseService = firebaseService
        self.userPath = userId
    }
    
    func addShop(_ shop: Shop, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "shops/\(userPath)/\(shop.id)"
        firebaseService.create(shop, at: path, completion: completion)
    }
    
    func observeShops(onChange: @escaping ([Shop]) -> Void) -> ObserverHandle {
        let path = "shops/\(userPath)"
        return firebaseService.observeList(path, as: Shop.self, onChange: onChange)
    }
    
    func deleteAllShops(completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "shops/\(userPath)"
        firebaseService.delete(at: path, completion: completion)
    }
}
