//
//  AddProductViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

class AddProductViewModel {
    
    private let combinedRepository: CombinedRepositoryProtocol
    private let authService: AuthService
    
    private var existingProduct: Product?
    private let searchString: String?
    
    var currentCategory: ProductCategory = .other
    var name: String = ""
    var description: String = ""
    private let categoriser = ProductCategoriser()
    
    var viewTitle: String
    
    var onProductUpdated: (() -> Void)?
    var onCategoryUpdated: (() -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?
    var onSuccess: (() -> Void)?
    var onCancel: (() -> Void)?
    
    init(withExistingProduct product: Product? = nil,
         searchString: String? = nil,
         combinedRepository: CombinedRepositoryProtocol,
         authService: AuthService){
        
        self.existingProduct = product
        self.combinedRepository = combinedRepository
        self.authService = authService
        self.searchString = searchString
        
        if product == nil {
            viewTitle = "Add a new item"
        } else {
            viewTitle = "Edit item"
        }
    }
    
    func populateTextFields() {
        if let searchString = searchString {
            self.name = searchString
            updateCategory(for: searchString)
            onProductUpdated?()
        } else if let existingProduct = existingProduct {
            self.name = existingProduct.name
            self.description = existingProduct.description
            self.currentCategory = existingProduct.category
            onProductUpdated?()
        }
    }
    
    func setName(_ name: String) {
        self.name = name
        updateCategory(for: name)
    }
    
    func setDescription(_ description: String) {
        self.description = description
    }
    
    func saveProduct() {
        
        guard !name.isEmpty else {
            onError?(ProductValidationError.emptyName)
            return
        }
        
        if let existingProduct = existingProduct {
            //update
            onLoading?(true)
            let updatedProduct = Product(id: existingProduct.id, name: name, description: description, category: currentCategory, authorUid: existingProduct.authorUid)
            combinedRepository.updateProduct(updatedProduct) { [weak self] result in
                self?.onLoading?(false)
                switch result {
                case .success(()):
                    self?.onSuccess?()
                case .failure(let error):
                    self?.onError?(error)
                }
            }
        } else {
            //add new
            let newProduct = Product(id: UUID().uuidString, name: name, description: description, category: currentCategory, authorUid: authService.currentUserId!)
            
            onLoading?(true)
            combinedRepository.addProduct(newProduct) { [weak self] result in
                self?.onLoading?(false)
                switch result {
                case .success(()):
                    self?.onSuccess?()
                case .failure(let error):
                    self?.onError?(error)
                }
            }
        }
    }
    
    private func updateCategory(for name: String) {
        currentCategory = categoriser.categorise(itemName: name)
        onCategoryUpdated?()
        
    }
    
    func getCategories() -> [ProductCategory] {
        return ProductCategory.allCases
    }
    
    func selectCategory(_ category: ProductCategory) {
        currentCategory = category
        onCategoryUpdated?()
    }
    
}
