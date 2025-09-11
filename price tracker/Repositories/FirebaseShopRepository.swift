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
    private let datasetId: String
    
    init(firebaseService: FirebaseDatabaseService, datasetId: String) {
        self.firebaseService = firebaseService
        self.datasetId = datasetId
    }
    
    func addShop(_ shop: Shop, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "datasets/\(datasetId)/shops/\(shop.id)"
        firebaseService.create(shop, at: path, completion: completion)
    }
    
    func observeShops(onChange: @escaping ([Shop]) -> Void) -> ObserverHandle {
        let path = "datasets/\(datasetId)/shops"
        return firebaseService.observeList(path, as: Shop.self, onChange: onChange)
    }
    
    func deleteAllShops(completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "datasets/\(datasetId)/shops"
        firebaseService.delete(at: path, completion: completion)
    }
}
