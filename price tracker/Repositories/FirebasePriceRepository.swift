//
//  FirebasePriceRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 02/09/2025.
//

protocol PriceRepository {
    func addPrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void)
    func updatePrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void)
    func deletePrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void)
    func observePrices(onChange: @escaping ([Price]) -> Void) -> ObserverHandle
    func deleteAllPrices(completion: @escaping (Result<Void, Error>) -> Void)
}

class FirebasePriceRepository: PriceRepository {
    private let firebaseService: FirebaseDatabaseService
    private let userPath: String
    
    init(firebaseService: FirebaseDatabaseService, userId: String) {
        self.firebaseService = firebaseService
        self.userPath = userId
    }
    
    func addPrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "prices/\(userPath)/\(price.productId)/\(price.id)"
        firebaseService.create(price, at: path, completion: completion)
    }
    
    func updatePrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "prices/\(userPath)/\(price.productId)/\(price.id)"
        firebaseService.update(price, at: path, completion: completion)
    }
    
    func deletePrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "prices/\(userPath)/\(price.productId)/\(price.id)"
        firebaseService.delete(at: path, completion: completion)
    }
    
    func observePrices(onChange: @escaping ([Price]) -> Void) -> ObserverHandle {
        let path = "prices/\(userPath)"
        return firebaseService.observeNestedUnkeyedList(path, as: Price.self, onChange: onChange)
    }
    
    func deleteAllPrices(completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "prices/\(userPath)"
        firebaseService.delete(at: path, completion: completion)
    }
}
