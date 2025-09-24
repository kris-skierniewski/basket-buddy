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
    var onShopChangedCallbacks: [String: [(Shop?) -> Void]] = [:]
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
    
    func deleteShop(_ shop: Shop, completion: @escaping (Result<Void, any Error>) -> Void) {
        if let matchingShopIndex = mockShops.firstIndex(where: { $0.id == shop.id }) {
            mockShops.remove(at: matchingShopIndex)
            triggerObservers(for: shop.id)
            triggerObservers()
        }
    }
    
    func updateShop(_ shop: Shop, completion: @escaping (Result<Void, any Error>) -> Void) {
        if let matchingShopIndex = mockShops.firstIndex(where: { $0.id == shop.id }) {
            mockShops[matchingShopIndex] = shop
            triggerObservers(for: shop.id)
        }
        completion(.success(()))
    }
    
    func observeShop(withId shopId: String, onChange: @escaping (Shop?) -> Void) -> any ObserverHandle {
        var callbacks = onShopChangedCallbacks[shopId] ?? []
        callbacks.append(onChange)
        onShopChangedCallbacks[shopId] = callbacks
        let matchingShop = mockShops.first(where: { $0.id == shopId })
        onChange(matchingShop)
        return MockObserverHandle()
    }
    
    func triggerObservers(for shopId: String) {
        let callBacks = onShopChangedCallbacks[shopId] ?? []
        let shop = mockShops.first(where: { $0.id == shopId })
        
        callBacks.forEach({
            $0(shop)
        })
    }
    
    
    func triggerObservers() {
        onChangeCallBacks.forEach { callback in
            callback(mockShops)
        }
    }
    
    
    
}
