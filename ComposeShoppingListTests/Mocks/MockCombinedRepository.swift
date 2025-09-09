//
//  MockCombinedRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

@testable import price_tracker

class MockCombinedRepository: CombinedRepositoryProtocol {
    
    var mockProductsWithPrices: [ProductWithPrices] = []
    var mockShops: [Shop] = []
    var mockUserPreferences: UserPreferences?
    var mockShoppingList: EnrichedShoppingList?
    
    private var onChangeCallBacks: [(([ProductWithPrices]) -> Void)] = []
    
    private var onShopsChangeCallBacks: [(([Shop]) -> Void)] = []
    
    private var onPreferencesChangeCallBacks: [(UserPreferences?) -> Void] = []
    
    private var onShoppingListChangeCallBacks: [((EnrichedShoppingList?) -> Void)] = []
    
    func observeProductsWithPrices(onChange: @escaping ([ProductWithPrices]) -> Void) -> [ObserverHandle] {
        let mockProductHandle = MockObserverHandle()
        
        let mockShopHandle = MockObserverHandle()
        
        let mockPriceHandle = MockObserverHandle()
        
        onChangeCallBacks.append(onChange)
        onChange(mockProductsWithPrices)
        
        return [mockProductHandle, mockShopHandle, mockPriceHandle]
    }
    
    func observeShops(onChange: @escaping ([price_tracker.Shop]) -> Void) -> any price_tracker.ObserverHandle {
        onShopsChangeCallBacks.append(onChange)
        onChange(mockShops)
        return MockObserverHandle()
    }
    
    func addProduct(_ product: Product, completion: @escaping (Result<Void, any Error>) -> Void) {
        let newProduct = ProductWithPrices(product: product, priceHistory: [])
        mockProductsWithPrices.append(newProduct)
        triggerObservers()
        completion(.success(()))
    }
    
    func updateProduct(_ product: Product, completion: @escaping (Result<Void, any Error>) -> Void) {
        if let index = mockProductsWithPrices.firstIndex(where: { $0.product.id == product.id }) {
            
            let newProductWithPrices = ProductWithPrices(product: product, priceHistory: mockProductsWithPrices[index].priceHistory)
            mockProductsWithPrices[index] = newProductWithPrices
            triggerObservers()
        }
        completion(.success(()))
    }
    
    func deleteProduct(id: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        if let index = mockProductsWithPrices.firstIndex(where: { $0.product.id == id}) {
            mockProductsWithPrices.remove(at: index)
            triggerObservers()
        }
        completion(.success(()))
    }
    
    func addPrice(_ price: Price, completion: @escaping (Result<Void, any Error>) -> Void) {
        guard let productIndex = mockProductsWithPrices.firstIndex(where: { $0.product.id == price.productId }) else {
            completion(.failure(RepositoryError.productNotFound))
            return
        }
        
        guard let shop = mockShops.first(where: { $0.id == price.shopId }) else {
            completion(.failure(RepositoryError.shopNotFound))
            return
        }
        
        let currentProduct = mockProductsWithPrices[productIndex]
        
        var newPriceHistory = currentProduct.priceHistory
        newPriceHistory.append(PriceWithShop(price: price, shop: shop))
        let newProduct = ProductWithPrices(product: currentProduct.product, priceHistory: newPriceHistory)
        mockProductsWithPrices[productIndex] = newProduct
        
        triggerObservers()
        completion(.success(()))
    }
    
    func updatePrice(_ price: Price, completion: @escaping (Result<Void, any Error>) -> Void) {
        guard let productIndex = mockProductsWithPrices.firstIndex(where: { $0.product.id == price.productId }) else {
            completion(.failure(RepositoryError.productNotFound))
            return
        }
        
        guard let shop = mockShops.first(where: { $0.id == price.shopId }) else {
            completion(.failure(RepositoryError.shopNotFound))
            return
        }
        
        let currentProduct = mockProductsWithPrices[productIndex]
        
        var newPriceHistory = currentProduct.priceHistory
        if let index = newPriceHistory.firstIndex(where: { $0.price.id == price.id}) {
            newPriceHistory[index] = PriceWithShop(price: price, shop: newPriceHistory[index].shop)
        }
        let newProduct = ProductWithPrices(product: currentProduct.product, priceHistory: newPriceHistory)
        mockProductsWithPrices[productIndex] = newProduct
        
        triggerObservers()
        completion(.success(()))
    }
    
    func deletePrice(_ price: Price, completion: @escaping (Result<Void, any Error>) -> Void) {
        guard let productIndex = mockProductsWithPrices.firstIndex(where: { $0.product.id == price.productId }) else {
            completion(.failure(RepositoryError.productNotFound))
            return
        }
        
        let currentProduct = mockProductsWithPrices[productIndex]
        
        let newPriceHistory = currentProduct.priceHistory.filter({ $0.price.id != price.id})
        let newProduct = ProductWithPrices(product: currentProduct.product, priceHistory: newPriceHistory)
        mockProductsWithPrices[productIndex] = newProduct
        
        triggerObservers()
        completion(.success(()))
    }
    
    func addShop(_ shop: Shop, completion: @escaping (Result<Void, any Error>) -> Void) {
        mockShops.append(shop)
        triggerObservers()
        completion(.success(()))
    }
    
    var numberOfTimesDeleteAllUserDataCalled = 0
    func deleteAllUserData(completion: @escaping (Result<Void, any Error>) -> Void) {
        mockShops.removeAll()
        mockProductsWithPrices.removeAll()
        triggerObservers()
        completion(.success(()))
        numberOfTimesDeleteAllUserDataCalled += 1
    }
    
    func updateUserPreferences(_ prefs: UserPreferences, completion: @escaping (Result<Void, Error>) -> Void) {
        mockUserPreferences = prefs
        triggerObservers()
        completion(.success(()))
    }
    func deleteUserPreferences(completion: @escaping (Result<Void, Error>) -> Void) {
        mockUserPreferences = nil
        triggerObservers()
        completion(.success(()))
    }
    func observePreferences(onChange: @escaping (UserPreferences?) -> Void) -> ObserverHandle {
        onPreferencesChangeCallBacks.append(onChange)
        onChange(mockUserPreferences)
        return MockObserverHandle()
    }
    
    func updateShoppingList(_ shoppingList: EnrichedShoppingList, completion: @escaping (Result<Void, Error>) -> Void) {
        mockShoppingList = shoppingList
        triggerObservers()
        completion(.success(()))
    }
    func deleteShoppingList(completion: @escaping (Result<Void, Error>) -> Void) {
        mockShoppingList = nil
        triggerObservers()
        completion(.success(()))
    }
    func observeShoppingList(onChange: @escaping (EnrichedShoppingList?) -> Void) -> [ObserverHandle] {
        onShoppingListChangeCallBacks.append(onChange)
        triggerObservers()
        onChange(mockShoppingList)
        return [MockObserverHandle()]
    }
    
    private func combineShoppingList() {
        if let repoShoppingList = mockShoppingList?.repoShoppingList {
            
            let shoppingListProducts: [ShoppingListProduct] = repoShoppingList.products.compactMap { item in
                let matchingProduct = mockProductsWithPrices.first { productWithPrices in
                    productWithPrices.product.id == item.productId
                }
                if let matchingProduct = matchingProduct {
                    return ShoppingListProduct(productWithPrices: matchingProduct, isChecked: item.isChecked)
                } else {
                    return nil
                }
            }
            
            mockShoppingList = EnrichedShoppingList(id: repoShoppingList.id, products: shoppingListProducts)
            
        }
            
    }
    
    private func triggerObservers() {
        onChangeCallBacks.forEach { callback in
            callback(mockProductsWithPrices)
        }
        onShopsChangeCallBacks.forEach { callback in
            callback(mockShops)
        }
        onPreferencesChangeCallBacks.forEach { callback in
            callback(mockUserPreferences)
        }
        combineShoppingList()
        onShoppingListChangeCallBacks.forEach { callback in
            callback(mockShoppingList)
        }
    }
    
    
}
