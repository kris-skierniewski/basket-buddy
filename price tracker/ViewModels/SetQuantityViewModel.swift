//
//  SetQuantityViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 29/10/2025.
//

class SetQuantityViewModel {
    
    private var shoppingList: EnrichedShoppingList?
    private var observerHandles: [ObserverHandle] = []
    private var shoppingListProduct: ShoppingListProduct
    
    private let combinedRepository: CombinedRepositoryProtocol
    
    var onShoppingListProductUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onSuccess: (() -> Void)?
    
    var productName: String {
        return shoppingListProduct.productWithPrices.product.name
    }
    
    var quantity: Double? {
        return shoppingListProduct.quantity
    }
    
    var unit: Unit? {
        return shoppingListProduct.unit
    }
    
    init(combinedRepository: CombinedRepositoryProtocol, shoppingListProduct: ShoppingListProduct) {
        self.combinedRepository = combinedRepository
        self.shoppingListProduct = shoppingListProduct
    }
    
    func loadShoppingList() {
        observerHandles = combinedRepository.observeShoppingList(onChange: { [weak self] updatedShoppingList in
            if let updatedShoppingList = updatedShoppingList {
                self?.shoppingList = updatedShoppingList
            }
        })
    }
    
    func setQuantity(_ quantity: Double) {
        shoppingListProduct.quantity = quantity
    }
    
    func setUnit(_ unit: Unit) {
        shoppingListProduct.unit = unit
    }
    
    func save() {
        guard var shoppingList = shoppingList else {
            onError?(RepositoryError.cannotFetchDataset)
            return
        }
        guard let productIndex = shoppingList.products.firstIndex(where: { $0.productWithPrices.product.id == shoppingListProduct.productWithPrices.product.id }) else {
            
            onError?(RepositoryError.productNotFound)
            return
        }
        
        shoppingList.products[productIndex].quantity = shoppingListProduct.quantity
        shoppingList.products[productIndex].unit = shoppingListProduct.unit
        
        combinedRepository.updateShoppingList(shoppingList) { [weak self] result in
            switch result {
            case .success():
                self?.onSuccess?()
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
}
