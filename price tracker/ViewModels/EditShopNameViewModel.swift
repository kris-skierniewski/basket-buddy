//
//  EditShopNameViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 24/09/2025.
//

class EditShopNameViewModel: KTableViewModel {
    
    var rightBarButtonItem: UIBarButtonItem? {
        UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
    }
    
    private let combinedRepository: CombinedRepositoryProtocol
    
    private var shopObserverHandle: ObserverHandle?
    
    private let shopId: String
    private var shop: Shop?
    private var newDisplayName: String = ""
    
    var navigationTitle: String = "Shop name"
    
    var sections: [KTableViewSection] = []
    
    var onSectionsUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onCompleted: (() -> Void)?
    
    
    init(combinedRepository: CombinedRepositoryProtocol, shopId: String) {
        self.shopId = shopId
        self.combinedRepository = combinedRepository
    }
    
    deinit {
        shopObserverHandle?.remove()
    }
    
    
    func loadSections() {
        shopObserverHandle = combinedRepository.observeShop(withId: shopId) { [weak self] shop in
            if let shop = shop {
                self?.shop = shop
                self?.newDisplayName = shop.name
            }
            self?.updateSections()
        }
    }
    
    private func updateSections() {
        let displayNameRow = KTableViewRow(placeholder: "Shop name", text: shop?.name) { [weak self] newName in
            self?.newDisplayName = newName
        }
        sections = [KTableViewSection(title: "Edit shop name", body: "", rows: [displayNameRow])]
        onSectionsUpdated?()
    }
    
    @objc private func saveTapped() {
        guard !newDisplayName.isEmpty else {
            onError?(AuthenticationError.displayNameEmpty)
            return
        }
        
        guard let shop = shop else {
            onError?(RepositoryError.shopNotFound)
            return
        }
        
        if newDisplayName == shop.name {
            onCompleted?()
            return
        }
        
        let updatedShop = Shop(id: shopId, name: newDisplayName)
        combinedRepository.updateShop(updatedShop) { [weak self] result in
            switch result {
            case .success(()):
                self?.onCompleted?()
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    
}
