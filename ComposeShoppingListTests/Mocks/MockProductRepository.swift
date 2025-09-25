//
//  MockProductRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 01/09/2025.
//

@testable import price_tracker

class MockObserverHandle: ObserverHandle {
    var hasBeenRemoved: Bool = false
    
    func remove() {
        hasBeenRemoved = true
    }
    
}

class MockProductRepository: ProductRepository {
    
    var mockProducts: [Product] = []
    
    private var onChangeCallBacks: [(([Product]) -> Void)] = []
    private var mockHandles: [MockObserverHandle] = []
    
    
    func addProduct(_ product: Product, completion: @escaping (Result<Void, any Error>) -> Void) {
        mockProducts.append(product)
        triggerObservers()
        completion(.success(()))
    }
    
    func updateProduct(_ product: Product, completion: @escaping (Result<Void, any Error>) -> Void) {
        if let index = mockProducts.firstIndex(where: { $0.id == product.id }) {
            mockProducts[index] = product
            triggerObservers()
        }
        completion(.success(()))
    }
    
    func updateProducts(_ products: [String : Any], completion: @escaping (Result<Void, any Error>) -> Void) {
        completion(.success(()))
    }
    
    func deleteProduct(id: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        mockProducts.removeAll { $0.id == id }
        triggerObservers()
        completion(.success(()))
    }
    
    func observeProducts(onChange: @escaping ([Product]) -> Void) -> any ObserverHandle {
        onChangeCallBacks.append(onChange)
        let handle = MockObserverHandle()
        mockHandles.append(handle)
        
        onChange(mockProducts)
        
        return handle
    }
    
    func deleteAllProducts(completion: @escaping (Result<Void, any Error>) -> Void) {
        mockProducts = []
        triggerObservers()
        completion(.success(()))
    }
    
    func getProducts() async throws -> [Product] {
        return mockProducts
    }
    
    
    func triggerObservers() {
        onChangeCallBacks.forEach { callback in
            callback(mockProducts)
        }
    }
    
}
