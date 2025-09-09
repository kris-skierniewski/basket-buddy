//
//  ProductDetailViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

//observe product
//observe prices for product

class ProductDetailViewModel {
    
    private let combinedRepository: CombinedRepositoryProtocol
    private var observerHandles: [ObserverHandle] = []
    private var preferencesObserverHandle: ObserverHandle?
    
    var product: ProductWithPrices
    
    var onProductUpdated: ((ProductWithPrices, ProductWithPrices) -> Void)?
    var onError: ((Error) -> Void)?
    
    var onCurrencyUpdated: ((Currency) -> Void)?
    var onEditProductButtonTapped: ((ProductWithPrices) -> Void)?
    var onAddPriceButtonTapped: (() -> Void)?
    var onEditPriceButtonTapped: ((PriceWithShop) -> Void)?
    
    var productName: String {
        return product.product.name
    }
    
    var productDescription: String {
        return product.product.description
    }
    
    var currency: Currency = .gbp
    
    var prices: [PriceWithShop] {
        return product.priceHistory.sorted(by: {
            $0.price.timestamp > $1.price.timestamp
        })
    }
    
    init(product: ProductWithPrices, combinedRepository: CombinedRepositoryProtocol) {
        self.product = product
        self.combinedRepository = combinedRepository
    }
    
    func loadProduct() {
        observerHandles = combinedRepository.observeProductsWithPrices { products in
            if let updatedProduct = products.first(where: { $0.product.id == self.product.product.id}) {
                let oldProduct = self.product
                if oldProduct != updatedProduct {
                    self.product = updatedProduct
                    self.onProductUpdated?(oldProduct, updatedProduct)
                }
            }
        }
        preferencesObserverHandle = combinedRepository.observePreferences(onChange: { [weak self] prefs in
            if let prefs = prefs {
                self?.currency = prefs.currency
                self?.onCurrencyUpdated?(prefs.currency)
            }
        })
    }
    
    func removePrice(at index: Int) {
        guard index >= 0 && index < prices.count else {
            onError?(RepositoryError.invalidIndex)
            return
        }
        
        let priceWithShop = prices[index]
        
        // remove price from view model to keep in sync
        if let indexOfPriceInShop = product.priceHistory.firstIndex(where: { $0.price.id == priceWithShop.price.id }) {
            product.priceHistory.remove(at: indexOfPriceInShop)
        }
        
        combinedRepository.deletePrice(priceWithShop.price) { [weak self] result in
            switch result {
            case .success(()):
                break
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func editPrice(at index: Int) {
        guard index >= 0 && index < prices.count else {
            onError?(RepositoryError.invalidIndex)
            return
        }
        
        let priceWithShop = prices[index]
        onEditPriceButtonTapped?(priceWithShop)
        
    }
    
    deinit {
        print("product detail view model dealloced !")
        observerHandles.forEach({ $0.remove() })
    }
    
    
}
