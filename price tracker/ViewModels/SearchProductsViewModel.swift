//
//  SearchProductsViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 09/09/2025.
//
struct SearchProductsRow {
    let product: ProductWithPrices
    let exists: Bool
    let isInShoppingList: Bool
}

class SearchProductsViewModel {
    
    private let combinedRepository: CombinedRepositoryProtocol
    private let authService: AuthService
    
    private var productsObserverHandles: [ObserverHandle] = []
    private var shoppingListObserverHandles: [ObserverHandle] = []
    private var preferencesObserverHandle: ObserverHandle?
    private var userObserverHandle: ObserverHandle?
    
    private var searchString: String = ""
    private var allProducts: [ProductWithPrices] = []
    private var shoppingList: EnrichedShoppingList = EnrichedShoppingList()
    
    private var currentUser: User?
    
    var currency: Currency = .gbp
    var rows: [SearchProductsRow] = []
    var onRowsUpdated: (() -> Void)?
    var onCompleted: (() -> Void)?
    var onItemAddedToShoppingList: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    private var filteredProducts: [ProductWithPrices] = []
    
    init(combinedRepository: CombinedRepositoryProtocol, authService: AuthService) {
        self.combinedRepository = combinedRepository
        self.authService = authService
    }
    
    deinit {
        productsObserverHandles.forEach { $0.remove() }
        shoppingListObserverHandles.forEach({ $0.remove() })
        preferencesObserverHandle?.remove()
        userObserverHandle?.remove()
    }
    
    func loadProducts() {
        productsObserverHandles = combinedRepository.observeProductsWithPrices(onChange: { [weak self] updatedProducts in
            self?.allProducts = updatedProducts.sorted()
            self?.applyCurrentFilter()
        })
        
        shoppingListObserverHandles = combinedRepository.observeShoppingList(onChange: { [weak self] updatedShoppingList in
            if let updatedShoppingList = updatedShoppingList {
                self?.shoppingList = updatedShoppingList
                self?.applyCurrentFilter()
            }
        })
        preferencesObserverHandle = combinedRepository.observePreferences(onChange: { [weak self] prefs in
            if let prefs = prefs {
                self?.currency = prefs.currency
                self?.applyCurrentFilter()
            }
        })
        if let currentUserId = authService.currentUserId {
            userObserverHandle = combinedRepository.observeUser(withId: currentUserId, onChange: { [weak self] updatedUser in
                self?.currentUser = updatedUser
            })
        }
        
    }
    
    func search(_ searchString: String) {
        self.searchString = searchString
        applyCurrentFilter()
    }
    
    func select(row: Int) {
        guard row >= 0 && row < rows.count else {
            return
        }
        
        let selectedRow = rows[row]
        
        //if product does not exist then add it
        if selectedRow.exists {
            addProductToShoppingList(selectedRow.product)
        } else {
            
//            ProductCategoriser.shared.generateAICategory(name: selectedRow.product.product.name, description: "") { category in
//                
//                
//                
//            }
            
            addNewProductToRepository(selectedRow.product) { [weak self] result in
                switch result {
                case .success(()):
                    self?.addProductToShoppingList(selectedRow.product)
                case .failure(let error):
                    self?.onError?(error)
                }
            }
        }
    }
    
    func done() {
        onCompleted?()
    }
    
    private func addNewProductToRepository(_ product: ProductWithPrices, completion: @escaping ((Result<Void,Error>) -> Void)) {
        combinedRepository.addProduct(product.product) { [weak self] result in
            switch result {
            case .success():
                completion(.success(()))
                //update category behind the scenes, lets add product instantly and not make user wait
                var productToCategorise = product.product
                ProductCategoriser.shared.generateAICategory(name: productToCategorise.name, description: "") { category in
                    productToCategorise.category = category
                    self?.combinedRepository.updateProduct(productToCategorise) { _ in
                         
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func addProductToShoppingList(_ product: ProductWithPrices) {
        
        let shoppingListContainsProduct = shoppingList.products.contains {
            $0.productWithPrices.product.id == product.product.id
        }
        
        guard !shoppingListContainsProduct else {
            let error = RepositoryError.productAlreadyInShoppingList
            onError?(error)
            return
        }
        
        var newShoppingList = shoppingList
        let newShoppingListProduct = ShoppingListProduct(productWithPrices: product, isChecked: false)
        newShoppingList.products.append(newShoppingListProduct)
        DonationManager.shared.donateAddToShoppingList(itemName: product.product.name)
        combinedRepository.updateShoppingList(newShoppingList) { [weak self] result in
            switch result {
            case .success(()):
                self?.onItemAddedToShoppingList?()
               
            case .failure(let error):
                self?.onError?(error)
            }
        }
        
    }
    
    
    private func applyCurrentFilter() {
        if searchString == "" {
            filteredProducts = allProducts
            rows = filteredProducts.map {
                let isInShoppingList = shoppingList.isProductInList($0.product.id)
                return SearchProductsRow(product: $0, exists: true, isInShoppingList: isInShoppingList)
            }
        } else {
            filteredProducts = allProducts.filter({
                $0.product.name.lowercased().contains(searchString.lowercased()) ||
                $0.product.description.lowercased().contains(searchString.lowercased())
            })
            if filteredProducts.count == 0 {
                if let currentUser = currentUser {
                    let newProduct = ProductWithPrices(product: Product(id: UUID().uuidString, name: searchString, description: "", authorUid: currentUser.id), author: currentUser, priceHistory: [])
                    let newProductRow = SearchProductsRow(product: newProduct, exists: false, isInShoppingList: false)
                    rows = [newProductRow]
                } else {
                    rows = []
                }
                
            } else {
                rows = filteredProducts.map {
                    let isInShoppingList = shoppingList.isProductInList($0.product.id)
                    return SearchProductsRow(product: $0, exists: true, isInShoppingList: isInShoppingList)
                }
            }
        }
        onRowsUpdated?()
    }
    
    private func categoriseProduct(product: ProductWithPrices) {
        
    }
    
    
}
