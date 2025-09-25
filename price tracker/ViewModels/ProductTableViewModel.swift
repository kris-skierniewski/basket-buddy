//
//  ProductTableViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 29/08/2025.
//

import UIKit //should we be doing this ?

class ProductTableViewModel {
    
    private let combinedRepository: CombinedRepositoryProtocol
    private var observerHandles: [ObserverHandle] = []
    private var preferencesObserverHandle: ObserverHandle?
    private var shoppingListObserverHandles: [ObserverHandle] = []
    
    private var shoppingList = EnrichedShoppingList()
    
    private var allProducts: [ProductWithPrices] = []
    var filteredProducts: [ProductWithPrices] = []
    var searchString: String = ""
    var currency: Currency = .gbp
    
    var selectedFilter: ShopFilter = .all
    
    var onShareTapped: ((UIBarButtonItem) -> Void)?
    var onCurrencyUpdated: ((Currency) -> Void)?
    var onProductsUpdated: (([ProductWithPrices]) -> Void)?
    var onShoppingListUpdated: (() -> Void)?
    var onShopFilterButtonTapped: ((ShopFilter) -> Void)?
    var onError: ((Error) -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onProductSelected: ((ProductWithPrices) -> Void)?
    var onAddProductButtonTapped: ((String?) -> Void)?
    
    private var isDeletingProduct: Bool = false
    var onProductDeleted: ((Int) -> Void)?
    
    init(combinedRepository: CombinedRepositoryProtocol) {
        self.combinedRepository = combinedRepository
    }
    
    func loadProducts() {
        onLoading?(true)
        observerHandles = combinedRepository.observeProductsWithPrices(onChange: { [weak self] products in
            if self?.isDeletingProduct != true {
                self?.allProducts = products
                self?.applyCurrentFilter()
            }
            self?.onLoading?(false)
        })
        preferencesObserverHandle = combinedRepository.observePreferences(onChange: { [weak self] prefs in
            if let prefs = prefs {
                self?.currency = prefs.currency
                self?.onCurrencyUpdated?(prefs.currency)
            }
        })
        shoppingListObserverHandles = combinedRepository.observeShoppingList(onChange: { [weak self] shoppingList in
            if let shoppingList = shoppingList {
                self?.shoppingList = shoppingList
                self?.onShoppingListUpdated?()
            }
        })
    }
    
    func deleteProduct(atIndex: Int) {
        isDeletingProduct = true
        onLoading?(true)
        let productId = filteredProducts[atIndex].product.id
        
        let productIndexInAllProducts = allProducts.firstIndex(of: filteredProducts[atIndex])
        
        combinedRepository.deleteProduct(id: productId) { [weak self] result in
            self?.onLoading?(false)
            switch result {
            case .success:
                if let productIndexInAllProducts = productIndexInAllProducts {
                    self?.allProducts.remove(at: productIndexInAllProducts)
                }
                self?.filteredProducts.remove(at: atIndex)
                self?.onProductDeleted?(atIndex)
                self?.isDeletingProduct = false
                break // Will update via observer
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func isProductInShoppingList(product: ProductWithPrices) -> Bool {
        return shoppingList.products.contains(where: { $0.productWithPrices.product.id == product.product.id })
    }
    
    func addProductToShoppingList(productIndex: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let product = filteredProducts[productIndex]
        
        let shoppingListContainsProduct = shoppingList.products.contains {
            $0.productWithPrices.product.id == product.product.id
        }
        
        guard !shoppingListContainsProduct else {
            let error = RepositoryError.productAlreadyInShoppingList
            onError?(error)
            completion(.failure(error))
            return
        }
        
        var newShoppingList = shoppingList
        let newShoppingListProduct = ShoppingListProduct(productWithPrices: product, isChecked: false)
        newShoppingList.products.append(newShoppingListProduct)
        DonationManager.shared.donateAddToShoppingList(itemName: product.product.name)
        combinedRepository.updateShoppingList(newShoppingList) { result in
            switch result {
            case .success(()):
                completion(.success(()))
               
            case .failure(let error):
                self.onError?(error)
                completion(.failure(error))
            }
        }
        
    }
    
    func filter(with searchString: String) {
        self.searchString = searchString
        applyCurrentFilter()
    }
    
    func showShopFilters() {
        onShopFilterButtonTapped?(selectedFilter)
    }
    
    func setShopFilter(_ filter: ShopFilter) {
        selectedFilter = filter
        applyCurrentFilter()
    }
    
    func share(sourceView: UIBarButtonItem) {
        onShareTapped?(sourceView)
    }
    
    private func applyCurrentFilter() {
        
        let searchStringFilteredProducts = applySearchStringFilter(products: allProducts, searchString: searchString)
        
        let shopFilterFilteredProducts = applyShopFilter(products: searchStringFilteredProducts, shopFilter: selectedFilter)
        
        filteredProducts = shopFilterFilteredProducts.sorted()
        
        onProductsUpdated?(filteredProducts)
    }
    
    private func applySearchStringFilter(products: [ProductWithPrices], searchString: String) -> [ProductWithPrices] {
        if searchString == "" {
            return products
        } else {
            return products.filter({
                $0.product.name.lowercased().contains(searchString.lowercased()) || $0.product.description.lowercased().contains(searchString.lowercased())
            })
        }
    }
    
    private func applyShopFilter(products: [ProductWithPrices], shopFilter: ShopFilter) -> [ProductWithPrices] {
        if case .shop(let shop) = shopFilter {
            return products.filter({
                if let cheapestShop = $0.cheapestPrice?.shop {
                    return cheapestShop == shop
                }
                return false
            })
        } else {
            return products
        }
    }
    
    deinit {
        observerHandles.forEach({ $0.remove() })
        preferencesObserverHandle?.remove()
        shoppingListObserverHandles.forEach({$0.remove()})
    }
}
