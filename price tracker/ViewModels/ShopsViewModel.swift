//
//  Untitled.swift
//  price tracker
//
//  Created by Kris Skierniewski on 23/09/2025.
//

class ShopsViewModel: KTableViewModel {
    
    private let combinedRepository: CombinedRepositoryProtocol
    private var shopsObserverHandle: ObserverHandle?
    private var shops: [Shop] = []
    
    var sections: [KTableViewSection] = []
    
    var onError: ((Error) -> Void)?
    var onShopTapped: ((Shop) -> Void)?
    var onDeleteShop: ((Shop) -> Void)?
    var onSectionsUpdated: (() -> Void)?
    
    var navigationTitle: String {
        "Your shops"
    }
    
    var rightBarButtonItem: UIBarButtonItem?
    
    init(combinedRepository: CombinedRepositoryProtocol) {
        self.combinedRepository = combinedRepository
    }
    
    func loadSections() {
        shopsObserverHandle = combinedRepository.observeShops(onChange: { [weak self] shops in
            self?.shops = shops
            self?.setupSections()
        })
    }
    
    private func setupSections() {
        let rows = shops.sorted().map({ shop in
            let row = KTableViewRow(title: shop.name, subtitle: "", accessoryType: .disclosureIndicator)
            row.deleteBlock = { [weak self] in
                self?.onDeleteShop?(shop)
            }
            row.didSelectBlock = { [weak self] in
                self?.onShopTapped?(shop)
            }
            return row
        })
        let shopsSection = KTableViewSection(title: "", body: "Tap to edit a shop name or swipe left to delete permanently", rows: rows)
        self.sections = [shopsSection]
        self.onSectionsUpdated?()
    }
    
    func deleteShop(_ shop: Shop) {
        combinedRepository.deleteShop(shop) { [weak self] result in
            switch result {
            case .success():
                break
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
}
