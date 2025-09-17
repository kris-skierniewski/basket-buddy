//
//  FirebaseProductRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 29/08/2025.
//

protocol ProductRepository {
    func addProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void)
    func updateProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void)
    func updateProducts(_ products: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
    func deleteProduct(id: String, completion: @escaping (Result<Void, Error>) -> Void)
    func observeProducts(onChange: @escaping ([Product]) -> Void) -> ObserverHandle
    func deleteAllProducts(completion: @escaping (Result<Void, Error>) -> Void)
}

class FirebaseProductRepository: ProductRepository {
    private let firebaseService: FirebaseDatabaseService
    private let datasetId: String
    
    init(firebaseService: FirebaseDatabaseService, datasetId: String) {
        self.firebaseService = firebaseService
        self.datasetId = datasetId
    }
    
    func addProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "datasets/\(datasetId)/products/\(product.id)"
        firebaseService.create(product, at: path, completion: completion)
    }
    
    func updateProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "datasets/\(datasetId)/products/\(product.id)"
        firebaseService.update(product, at: path, completion: completion)
    }
    
    func updateProducts(_ products: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "datasets/\(datasetId)/products"
        firebaseService.updateItems(products, at: path, completion: completion)
    }
    
    func deleteProduct(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "datasets/\(datasetId)/products/\(id)"
        firebaseService.delete(at: path, completion: completion)
    }
    
    func observeProducts(onChange: @escaping ([Product]) -> Void) -> ObserverHandle {
        let path = "datasets/\(datasetId)/products"
        return firebaseService.observeList(path, as: Product.self, onChange: onChange)
    }
    
    func deleteAllProducts(completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "datasets/\(datasetId)/products"
        firebaseService.delete(at: path, completion: completion)
    }
}
