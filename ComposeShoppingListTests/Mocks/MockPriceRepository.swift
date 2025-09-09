//
//  MockPriceRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

@testable import price_tracker

class MockPriceRepository: PriceRepository {
    
    var mockPrices: [Price] = []
    
    private var onChangeCallBacks: [(([Price]) -> Void)] = []
    private var mockHandles: [MockObserverHandle] = []
    
    
    func addPrice(_ price: Price, completion: @escaping (Result<Void, any Error>) -> Void) {
        mockPrices.append(price)
        triggerObservers()
        completion(.success(()))
    }
    
    func updatePrice(_ price: Price, completion: @escaping (Result<Void, any Error>) -> Void) {
        if let index = mockPrices.firstIndex(where: { $0.id == price.id }) {
            mockPrices[index] = price
            triggerObservers()
        }
        completion(.success(()))
    }
    
    func deletePrice(_ price: Price, completion: @escaping (Result<Void, any Error>) -> Void) {
        mockPrices.removeAll { $0.id == price.id }
        triggerObservers()
        completion(.success(()))
    }
    
    func observePrices(onChange: @escaping ([Price]) -> Void) -> any ObserverHandle {
        onChangeCallBacks.append(onChange)
        let handle = MockObserverHandle()
        mockHandles.append(handle)
        
        onChange(mockPrices)
        
        return handle
    }
    
    func deleteAllPrices(completion: @escaping (Result<Void, any Error>) -> Void) {
        mockPrices = []
        triggerObservers()
        completion(.success(()))
    }
    
    func triggerObservers() {
        onChangeCallBacks.forEach { callback in
            callback(mockPrices)
        }
    }
    
}
