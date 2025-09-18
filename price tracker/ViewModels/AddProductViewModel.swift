//
//  AddProductViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//
import FoundationModels

class AddProductViewModel {
    
    private let combinedRepository: CombinedRepositoryProtocol
    private let authService: AuthService
    
    private var existingProduct: Product?
    private let searchString: String?
    
    private var classificationTask: Task<Void, Never>?
    
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
    var onCategoryLoading: ((Bool) -> Void)?
    
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
        generateAICategory()
    }
    
    func setDescription(_ description: String) {
        self.description = description
        generateAICategory()
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
    
    func generateAICategory() {
        classificationTask?.cancel()
        classificationTask = Task { [weak self] in
            
            let debounceDelay: TimeInterval = 0.5
            try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await self?.performClassification()
            
        }
    }
    
    @MainActor
    private func performClassification() async {
        if #available(iOS 26.0, *) {
            
            guard !name.isEmpty else { return }
            guard SystemLanguageModel.default.isAvailable else { return }
            let session = LanguageModelSession()
            let prompt = """
                You are classifying grocery items into standard supermarket categories
                to make them easier to find. Return the one category that is most fitting for item with name: \(name), and description: \(description).
                """
            do {
                onCategoryLoading?(true)
                let response = try await session.respond(to: prompt, generating: GenerableProductCategory.self)
                let generableCategory = response.content
                if let productCategory = ProductCategory(rawValue: generableCategory.rawValue) {
                    selectCategory(productCategory)
                }
                onCategoryLoading?(false)
            } catch {
                onCategoryLoading?(false)
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
