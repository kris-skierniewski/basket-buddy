//
//  ShoppingListViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 08/09/2025.
//

class ShoppingListViewModel {
    
    private let combinedRepository: CombinedRepositoryProtocol
    
    private var shoppingList: EnrichedShoppingList = EnrichedShoppingList()
    private var observerHandles: [ObserverHandle] = []
    
    var numberOfItems: Int {
        return shoppingList.products.count
    }
    var sections: [ShoppingListSection] = []
    
    var onContentsChanged: ((SectionedDiff) -> Void)?
    var onError: ((Error) -> Void)?
    
    init(combinedRepository: CombinedRepositoryProtocol) {
        self.combinedRepository = combinedRepository
    }
    
    
    func loadShoppingList() {
        observerHandles = combinedRepository.observeShoppingList(onChange: { [weak self] shoppingList in
            if let shoppingList = shoppingList {
                self?.shoppingList = shoppingList
                self?.groupProductsByCategory()
            }
        })
    }
    
    func markCompleted(completed: Bool, atIndexPath indexPath: IndexPath) {
        guard indexPath.section >= 0 && indexPath.section < sections.count else {
            onError?(RepositoryError.invalidIndex)
            return
        }
        
        guard indexPath.row >= 0 && indexPath.row < sections[indexPath.section].products.count else {
            onError?(RepositoryError.invalidIndex)
            return
        }
        
        let product = sections[indexPath.section].products[indexPath.row]
        
        var newShoppingList = shoppingList
        if let shoppingListProductIndex = shoppingList.products.firstIndex(of: product) {
            newShoppingList.products[shoppingListProductIndex].isChecked = completed
            combinedRepository.updateShoppingList(newShoppingList) { [weak self] result in
                switch result {
                case .success(()):
                    let generator = UINotificationFeedbackGenerator()
                    generator.prepare()
                    generator.notificationOccurred(.success)
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
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.success)
                break
            case .failure(let error):
                self?.onError?(error)
            }
        }
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
