//
//  CombinedRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 02/09/2025.
//

protocol CombinedRepositoryProtocol {
    func observeProductsWithPrices(onChange: @escaping ([ProductWithPrices]) -> Void) -> [ObserverHandle]
    
    func observeShops(onChange: @escaping ([Shop]) -> Void) -> ObserverHandle
    func addShop(_ shop: Shop, completion: @escaping (Result<Void, Error>) -> Void)
    
    func addProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void)
    func updateProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteProduct(id: String, completion: @escaping (Result<Void, Error>) -> Void)
    
    func addPrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void)
    func deletePrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void)
    func updatePrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void)
    
    func updateUserPreferences(_ prefs: UserPreferences, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteUserPreferences(completion: @escaping (Result<Void, Error>) -> Void)
    func observePreferences(onChange: @escaping (UserPreferences?) -> Void) -> ObserverHandle
    
    func updateShoppingList(_ shoppingList: EnrichedShoppingList, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteShoppingList(completion: @escaping (Result<Void, Error>) -> Void)
    func observeShoppingList(onChange: @escaping (EnrichedShoppingList?) -> Void) -> [ObserverHandle]
    
    func deleteAllUserData(completion: @escaping (Result<Void, Error>) -> Void)
    
    func updateUser(_ user: User, completion: @escaping (Result<Void, Error>) -> Void)
    func observeUser(withId userId: String, onChange: @escaping (User?) -> Void) -> ObserverHandle
    func deleteUser(_ user: User, completion: @escaping (Result<Void, Error>) -> Void)
    func observeUsers(onChange: @escaping ([User]) -> Void) -> ObserverHandle
}

class CombinedRepository: CombinedRepositoryProtocol {
    
    
    private let productRepository: ProductRepository
    private let shopRepository: ShopRepository
    private let priceRepository: PriceRepository
    private let shoppingListRepository: ShoppingListRepository
    private let userRepository: UserRepository
    
    private let userPreferencesRepository: UserPreferenceRepository
    
    private var currentProducts: [String: Product] = [:]
    private var currentShops: [String: Shop] = [:]
    private var currentUsers: [String: User] = [:]
    private var currentPrices: [Price] = []
    
    private var currentShoppingList: ShoppingList?
    private var currentProductsWithPrices: [ProductWithPrices] = []
    
    init(productRepository: ProductRepository,
        shopRepository: ShopRepository,
        priceRepository: PriceRepository,
         userPreferencesRepository: UserPreferenceRepository,
         shoppingListRepository: ShoppingListRepository,
         userRepository: UserRepository) {
        self.productRepository = productRepository
        self.shopRepository = shopRepository
        self.priceRepository = priceRepository
        self.userPreferencesRepository = userPreferencesRepository
        self.shoppingListRepository = shoppingListRepository
        self.userRepository = userRepository
    }
    
    func observeProductsWithPrices(onChange: @escaping ([ProductWithPrices]) -> Void) -> [ObserverHandle] {
        let productHandle = productRepository.observeProducts { [weak self] products in
            self?.combineData(products: products, onChange: onChange)
        }
        
        let shopHandle = shopRepository.observeShops { [weak self] shops in
            self?.combineData(shops: shops, onChange: onChange)
        }
        
        let priceHandle = priceRepository.observePrices { [weak self] prices in
            self?.combineData(prices: prices, onChange: onChange)
        }
        
        let userHandle = userRepository.observeUsers { [weak self] users in
            self?.combineData(users: users, onChange: onChange)
        }
        
        return [productHandle, shopHandle, priceHandle, userHandle]
    }
    
    func observeShops(onChange: @escaping ([Shop]) -> Void) -> any ObserverHandle {
        return shopRepository.observeShops(onChange: onChange)
    }
    
    private func combineData(products: [Product]? = nil,
                             shops: [Shop]? = nil,
                             prices: [Price]? = nil,
                             users: [User]? = nil,
                             onChange: @escaping ([ProductWithPrices]) -> Void) {
        if let products = products { currentProducts = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) }) }
        if let shops = shops { currentShops = Dictionary(uniqueKeysWithValues: shops.map { ($0.id, $0) }) }
        if let prices = prices { currentPrices = prices }
        if let users = users { currentUsers = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) }) }
        
        let enriched: [ProductWithPrices] = currentProducts.values.compactMap { product in
            let productPrices: [PriceWithShop] = currentPrices
                .filter { $0.productId == product.id }
                .compactMap { price in
                    guard let shop = currentShops[price.shopId] else { return nil }
                    guard let author = currentUsers[price.authorUid] else { return nil }
                    return PriceWithShop(price: price, author: author, shop: shop)
                }
            
            if let user = currentUsers[product.authorUid] {
                
                return ProductWithPrices(product: product, author: user, priceHistory: productPrices)
            } else {
                return nil
            }
        }
        
        onChange(enriched)
    }
    
    private func combineData(shoppingList: ShoppingList? = nil, productsWithPrices: [ProductWithPrices]? = nil, onChange: @escaping (EnrichedShoppingList?) -> Void) {
        if let shoppingList = shoppingList {
            currentShoppingList = shoppingList
        }
        if let productsWithPrices = productsWithPrices {
            currentProductsWithPrices = productsWithPrices
        }
        if let currentShoppingList = currentShoppingList {
            let shoppingListProducts = currentShoppingList.products.compactMap { item in
                if let product = currentProductsWithPrices.first(where: { $0.product.id == item.productId }) {
                    return ShoppingListProduct(productWithPrices: product, isChecked: item.isChecked)
                }
                return nil
            }
            let enrichedShoppingList = EnrichedShoppingList(id: currentShoppingList.id, products: shoppingListProducts)
            onChange(enrichedShoppingList)
        } else {
            onChange(nil)
        }
    }
    
    func addProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        productRepository.addProduct(product, completion: completion)
    }
    func updateProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        productRepository.updateProduct(product, completion: completion)
    }
    func deleteProduct(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        productRepository.deleteProduct(id: id, completion: completion)
    }
    
    func addShop(_ shop: Shop, completion: @escaping (Result<Void, Error>) -> Void) {
        shopRepository.addShop(shop, completion: completion)
    }
    
    
    func addPrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void) {
        priceRepository.addPrice(price, completion: completion)
    }
    func deletePrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void) {
        priceRepository.deletePrice(price, completion: completion)
    }
    func updatePrice(_ price: Price, completion: @escaping (Result<Void, Error>) -> Void) {
        priceRepository.updatePrice(price, completion: completion)
    }
    
    func deleteAllUserData(completion: @escaping (Result<Void, Error>) -> Void) {
        #warning("finish this!")
        //TODO: needs to remove user from dataset and delete dataset if they're the only user !
        priceRepository.deleteAllPrices { [weak self] result in
            switch result {
            case .success(()):
                
                self?.shopRepository.deleteAllShops { result in
                    switch result {
                    case .success(()):
                        self?.productRepository.deleteAllProducts(completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateUserPreferences(_ prefs: UserPreferences, completion: @escaping (Result<Void, Error>) -> Void) {
        userPreferencesRepository.updateUserPreferences(prefs, completion: completion)
    }
    func deleteUserPreferences(completion: @escaping (Result<Void, Error>) -> Void) {
        userPreferencesRepository.deleteUserPreferences(completion: completion)
    }
    func observePreferences(onChange: @escaping (UserPreferences?) -> Void) -> ObserverHandle {
        return userPreferencesRepository.observePreferences(onChange: onChange)
    }
    
    func updateShoppingList(_ shoppingList: EnrichedShoppingList, completion: @escaping (Result<Void, Error>) -> Void) {
        shoppingListRepository.updateShoppingList(shoppingList.repoShoppingList, completion: completion)
    }
    func deleteShoppingList(completion: @escaping (Result<Void, Error>) -> Void) {
        shoppingListRepository.deleteShoppingList(completion: completion)
    }
    func observeShoppingList(onChange: @escaping (EnrichedShoppingList?) -> Void) -> [ObserverHandle] {
        
        let productsHandles = observeProductsWithPrices { [weak self] productsWithPrices in
            self?.combineData(productsWithPrices: productsWithPrices, onChange: onChange)
        }
        
        let shoppingListHandle = shoppingListRepository.observeShoppingList { [weak self] shoppingList in
            self?.combineData(shoppingList: shoppingList, onChange: onChange)
        }
        
        var handles = [shoppingListHandle]
        handles.append(contentsOf: productsHandles)
        return handles
    }
    
    func updateUser(_ user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        userRepository.updateUser(user, completion: completion)
    }
    func observeUser(withId userId: String, onChange: @escaping (User?) -> Void) -> ObserverHandle {
        userRepository.observeUser(withId: userId, onChange: onChange)
    }
    func deleteUser(_ user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        userRepository.deleteUser(user, completion: completion)
    }
    func observeUsers(onChange: @escaping ([User]) -> Void) -> ObserverHandle {
        userRepository.observeUsers(onChange: onChange)
    }
}
