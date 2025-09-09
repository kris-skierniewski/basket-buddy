//
//  MockShopRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

@testable import price_tracker

class MockShopRepository: ShopRepository {
    
    var mockShops: [Shop] = []
    
    private var onChangeCallBacks: [(([Shop]) -> Void)] = []
    private var mockHandles: [MockObserverHandle] = []
    
    
    func addShop(_ shop: Shop, completion: @escaping (Result<Void, any Error>) -> Void) {
        mockShops.append(shop)
        triggerObservers()
        completion(.success(()))
    }
    
    func observeShops(onChange: @escaping ([Shop]) -> Void) -> any ObserverHandle {
        onChangeCallBacks.append(onChange)
        let handle = MockObserverHandle()
        mockHandles.append(handle)
        
        onChange(mockShops)
        
        return handle
    }
    
    func deleteAllShops(completion: @escaping (Result<Void, any Error>) -> Void) {
        mockShops = []
        triggerObservers()
        completion(.success(()))
    }
    
    
    func triggerObservers() {
        onChangeCallBacks.forEach { callback in
            callback(mockShops)
        }
    }
    
    
    
}
