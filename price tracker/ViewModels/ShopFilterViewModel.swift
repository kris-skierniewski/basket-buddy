//
//  ShopFilterViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 09/09/2025.
//

enum ShopFilter: DiffableItem {
    
    case all
    case shop(Shop)
    
    var diffIdentifier: String {
        if case .shop(let shop) = self {
            return shop.id
        } else {
            return "all"
        }
    }
    
    var title: String {
        if case .shop(let shop) = self {
            return shop.name
        } else {
            return "All shops"
        }
    }
}

struct ShopFilterSection: DiffableSectionProtocol {
    var items: [ShopFilter]
    
    typealias Item = ShopFilter
    
    var id: String
    
    
}

class ShopFilterViewModel {
    
    let combinedRepository: CombinedRepositoryProtocol
    
    private var shops: [Shop] = []
    
    var observerHandle: ObserverHandle?
    
    
    var sections: [ShopFilterSection] = []
    var selectedFilter: ShopFilter
    
    var onDismiss: ((ShopFilter) -> Void)?
    var onFilterSelected: ((ShopFilter) -> Void)?
    var onContentsChanged: ((SectionedDiff) -> Void)?
    
    init(combinedRepository: CombinedRepositoryProtocol, selectedFilter: ShopFilter) {
        self.combinedRepository = combinedRepository
        self.selectedFilter = selectedFilter
    }
    
    deinit {
        observerHandle?.remove()
    }
    
    func loadShops() {
        observerHandle = combinedRepository.observeShops(onChange: { [weak self] shops in
            self?.shops = shops
            self?.updateSections()
        })
    }
    
    private func updateSections() {
        let sortedShopFilters = shops.sorted().map({ ShopFilter.shop($0) })
        let allFilters = [ShopFilter.all] + sortedShopFilters
        
        let section = ShopFilterSection(items: allFilters, id: "shopfilters")
        let diff = SectionedDiffCalculator.diff(old: self.sections, new: [section])
        self.sections = [section]
        onContentsChanged?(diff)
    }
    
    func selectFilter(atIndex index: Int) {
        let filter = sections[0].items[index]
        self.selectedFilter = filter
        onFilterSelected?(filter)
    }
    
    func done() {
        onDismiss?(selectedFilter)
    }
    
}
