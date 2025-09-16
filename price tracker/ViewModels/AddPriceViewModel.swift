//
//  AddPriceViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

enum HighlightedInputField {
    case none
    case shop
    case price
    case quantity
    case unit
    case notes
}

protocol AddPriceViewModelDelegate: AnyObject {
    func viewModelDidUpdateShops(_ shops: [Shop])
    func viewModelDidUpdateFilteredShops(_ shops: [Shop])
    func viewModelDidUpdateUnits(_ units: [Unit])
}

class AddPriceViewModel {
    
    var onSuccess: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onCurrencyUpdated: ((Currency) -> Void)?
    
    private var existingPrice: Price?
    
    var viewTitle: String
    
    var selectedShop: Shop?
    var shopName: String = ""
    var price: Double?
    var quantity: Double?
    var unit: Unit?
    var notes: String = ""
    
    var currency: Currency = .gbp
    
    weak var delegate: AddPriceViewModelDelegate?
    
    private var observerHandle: ObserverHandle?
    private var preferencesObserverHandle: ObserverHandle?
    private var userObserverHandle: ObserverHandle?
    private var allShops: [Shop] = []
    private var filteredShops: [Shop] = []
    private var currentUser: User?
    
    private let combinedRepository: CombinedRepositoryProtocol
    private let authService: AuthService
    private let product: ProductWithPrices
    
    init(product: ProductWithPrices, existingPrice: PriceWithShop? = nil, combinedRepository: CombinedRepositoryProtocol, authService: AuthService) {
        self.product = product
        self.combinedRepository = combinedRepository
        self.authService = authService
        if let existingPrice = existingPrice {
            self.existingPrice = existingPrice.price
            self.selectedShop = existingPrice.shop
            self.shopName = existingPrice.shop.name
            self.price = existingPrice.price.price
            self.quantity = existingPrice.price.quantity
            self.unit = existingPrice.price.unit
            self.notes = existingPrice.price.notes ?? ""
            
            viewTitle = "Edit price"
        } else {
            viewTitle = "Add new price"
        }
    }
    
    deinit {
        observerHandle?.remove()
        preferencesObserverHandle?.remove()
        userObserverHandle?.remove()
    }
    
    func loadShopsAndUnits() {
        observerHandle = combinedRepository.observeShops(onChange: { [weak self] shops in
            self?.allShops = shops.sorted()
            self?.filterShops(with: self!.shopName)
            self?.delegate?.viewModelDidUpdateShops(shops)
        })
        
        preferencesObserverHandle = combinedRepository.observePreferences(onChange: { [weak self] prefs in
            if let prefs = prefs {
                self?.currency = prefs.currency
                self?.onCurrencyUpdated?(prefs.currency)
            }
        })
        if let currentUserId = authService.currentUserId {
            userObserverHandle = combinedRepository.observeUser(withId: currentUserId) { [weak self] updatedUser in
                self?.currentUser = updatedUser
            }
        }
        
        delegate?.viewModelDidUpdateUnits(Unit.allCases)
    }
    
    func filterShops(with searchString: String) {
        shopName = searchString
        if searchString.isEmpty {
            filteredShops = allShops
        } else {
            filteredShops = allShops.filter({
                $0.name.lowercased().contains(searchString.lowercased())
            })
        }
        delegate?.viewModelDidUpdateFilteredShops(filteredShops)
    }
    
    func getFilteredShops() -> [Shop] {
        return filteredShops
    }
    
    func selectShop(_ shop: Shop) {
        selectedShop = shop
        shopName = shop.name
    }
    
    func setShopName(_ shopName: String) {
        self.shopName = shopName
    }
    
    func setPrice(_ price: Double?) {
        self.price = price
    }
    
    func setQuantity(_ quantity: Double?) {
        self.quantity = quantity
    }
    
    func selectUnit(_ unit: Unit) {
        self.unit = unit
    }
    
    func setNotes(_ notes: String) {
        self.notes = notes
    }
    
    func savePrice() {
        
        guard validateInput() else { return }
        
        addNewShopIfNeeded { [weak self] result in
            switch result {
            case .success(let shop):
                self?.addOrUpdatePrice(withShop: shop) { result in
                    switch result {
                    case .success(()):
                        self?.onSuccess?()
                        
                    case .failure(let error):
                        self?.onError?(error)
                    }
                }
            case .failure(let error):
                self?.onError?(error)
            }
        }
        
    }
    
    private func addOrUpdatePrice(withShop shop: Shop, completion: @escaping (Result<Void,Error>) -> Void) {
        if let existingPrice = existingPrice {
            let price = Price(id: existingPrice.id, productId: existingPrice.productId, price: price!, shopId: shop.id, timestamp: existingPrice.timestamp, unit: unit!, quantity: quantity!, notes: notes, authorUid: existingPrice.authorUid)
            
            combinedRepository.updatePrice(price, completion: completion)
        } else {
            let price = Price(productId: product.product.id, price: price!, shopId: shop.id, unit: unit!, quantity: quantity!, notes: notes, authorUid: currentUser!.id)
            
            combinedRepository.addPrice(price, completion: completion)
            
        }
    }
    
    private func addNewShopIfNeeded(completion: @escaping (Result<Shop,Error>) -> Void) {
        var shouldAddNewShop = false
        
        var matchingShop = allShops.first(where: {
            $0.name.lowercased() == shopName.lowercased().trimmingCharacters(in: .whitespaces)
        })
        if matchingShop == nil {
            let newShopNameFormatted = shopName.capitalized.trimmingCharacters(in: .whitespaces)
            matchingShop = Shop(name: newShopNameFormatted)
            shouldAddNewShop = true
        }
        
        if shouldAddNewShop {
            combinedRepository.addShop(matchingShop!) { result in
                switch result {
                case .success(()):
                    completion(.success(matchingShop!))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success((matchingShop!)))
        }
    }
    
    private func validateInput() -> Bool {
        guard shopName.isEmpty == false else {
            onError?(ProductValidationError.emptyShopName)
            return false
        }
        
        guard let price = price, price > 0 else {
            onError?(ProductValidationError.emptyPrice)
            return false
        }
        
        guard let quantity = quantity, quantity > 0 else {
            onError?(ProductValidationError.emptyQuantity)
            return false
        }
        
        guard let _ = unit else {
            onError?(ProductValidationError.emptyUnit)
            return false
        }
        
        
        return true
    }
    
}
