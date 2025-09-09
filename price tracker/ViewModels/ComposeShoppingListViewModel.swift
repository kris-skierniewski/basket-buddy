//
//  ComposeShoppingListViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2025.
//

enum ShoppingListCategory: Hashable {
    case completed
    case productCategory(ProductCategory)
}

class ShoppingListSection: DiffableSectionProtocol {
    var items: [ShoppingListProduct] {
        return products
    }
    
    typealias Item = ShoppingListProduct
    
    var title: String {
        
        if case .productCategory(let productCategory) = category {
            return productCategory.rawValue.capitalized
        }
        return "Completed"
    }
    var id: String {
        if case .productCategory(let productCategory) = category {
            return productCategory.rawValue
        }
        return "completed"
    }
    var category: ShoppingListCategory
    var products: [ShoppingListProduct]
    
    init(category: ShoppingListCategory, products: [ShoppingListProduct]) {
        self.category = category
        self.products = products
    }
}

class ComposeShoppingListViewModel {
    
    private let combinedRepository: CombinedRepositoryProtocol
    private var shoppingList: EnrichedShoppingList = EnrichedShoppingList()
    private var observerHandles: [ObserverHandle] = []
    
    var sections: [ShoppingListSection] = []
    
    var numberOfItems: Int {
        return shoppingList.products.count
    }
    
    var onContentsChanged: ((SectionedDiff) -> Void)?
    var onStartTapped: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(combinedRepository: CombinedRepositoryProtocol) {
        self.combinedRepository = combinedRepository
    }
    
    deinit {
        observerHandles.forEach {
            $0.remove()
        }
    }
    
    func loadShoppingList() {
        observerHandles = combinedRepository.observeShoppingList(onChange: { [weak self] shoppingList in
            if let shoppingList = shoppingList {
                self?.shoppingList = shoppingList
                self?.groupProductsByCategory()
            }
        })
    }
    
    func addProduct(_ product: ProductWithPrices) {
        
        let shoppingListContainsProduct = shoppingList.products.contains {
            $0.productWithPrices.product.id == product.product.id
        }
        
        guard !shoppingListContainsProduct else {
            return
        }
        
        var newShoppingList = shoppingList
        let newProduct = ShoppingListProduct(productWithPrices: product, isChecked: false)
        newShoppingList.products.append(newProduct)
        combinedRepository.updateShoppingList(newShoppingList) { [weak self] result in
            switch result {
            case .success(()):
                break
            case .failure(let error):
                self?.onError?(error)
            }
        }
        
        //shoppingList.products.append(product)
        //groupProductsByCategory()
    }
    
    func removeProduct(atIndexPath indexPath: IndexPath) {
        let product = sections[indexPath.section].products[indexPath.row]
        if let index = shoppingList.products.firstIndex(of: product) {
            
            var newShoppingList = shoppingList
            newShoppingList.products.remove(at: index)
            combinedRepository.updateShoppingList(newShoppingList) { [weak self] result in
                switch result {
                case .success(()):
                    break
                case .failure(let error):
                    self?.onError?(error)
                }
            }
        }
    }
    
    func cleanUp() {
        let uncheckedProducts = shoppingList.products.filter({ !$0.isChecked })
        var newShoppingList = shoppingList
        newShoppingList.products = uncheckedProducts
        
        combinedRepository.updateShoppingList(newShoppingList) { [weak self] result in
            switch result {
            case .success(()):
                break
            case .failure(let error):
                self?.onError?(error)
            }
        }
        
    }
    
    func start() {
        onStartTapped?()
    }
    
    private func groupProductsByCategory() {
        let grouped = Dictionary(grouping: shoppingList.products) {
            if $0.isChecked {
                return ShoppingListCategory.completed
            } else {
                return ShoppingListCategory.productCategory($0.productWithPrices.product.category)
            }
        }
        let sections = grouped.map { ShoppingListSection(category: $0.key, products: $0.value)}
        let sortedSections = sections.sorted {
            if $0.category == .completed {
                return false
            } else if $1.category == .completed {
                return true
            } else {
                return $0.title < $1.title
            }
        }
        
        let diff = SectionedDiffCalculator.diff(old: self.sections, new: sortedSections)
        self.sections = sortedSections
        
        onContentsChanged?(diff)
    }
    
    
    
}
