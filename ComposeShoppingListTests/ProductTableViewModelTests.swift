//
//  ProductTableViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 01/09/2025.
//

@testable import price_tracker
import XCTest

final class ProductTableViewModelTests: XCTestCase {
    
    var viewModel: ProductTableViewModel!
    var mockRepository: MockCombinedRepository!
    let mockUser = User(id: "user1", displayName: "User 1")
    
    override func setUpWithError() throws {
        
        mockRepository = MockCombinedRepository()
        mockRepository.mockUsers = [mockUser]
        viewModel = ProductTableViewModel(combinedRepository: mockRepository)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testEmptyProducts() {
        viewModel.loadProducts()
        XCTAssertEqual(viewModel.filteredProducts.count, 0)
    }
    
    func testNonEmptyProductsList() {
        mockRepository.mockProductsWithPrices = [
            ProductWithPrices(product: Product(id: "1", name: "Apple", description: "green", authorUid: mockUser.id), author: mockUser, priceHistory: []),
            ProductWithPrices(product: Product(id: "2", name: "Banana", description: "", authorUid: mockUser.id), author: mockUser, priceHistory: [])
        ]
        viewModel.loadProducts()
        
        XCTAssertEqual(viewModel.filteredProducts.count, 2)
        XCTAssertEqual(viewModel.filteredProducts.first?.product.name, "Apple")
    }
    
    func testCanFilterProductsByName() {
        mockRepository.mockProductsWithPrices = [
            ProductWithPrices(product: Product(id: "1", name: "Apple", description: "green", authorUid: mockUser.id), author: mockUser, priceHistory: []),
            ProductWithPrices(product: Product(id: "2", name: "Banana", description: "", authorUid: mockUser.id), author: mockUser, priceHistory: [])
        ]
        viewModel.loadProducts()
        viewModel.filter(with: "ban")
        XCTAssertEqual(viewModel.filteredProducts.count, 1)
        XCTAssertEqual(viewModel.filteredProducts.first?.product.name, "Banana")
    }
    
    func testListObservesRepositoryChanges() {
        mockRepository.mockProductsWithPrices = [
            ProductWithPrices(product: Product(id: "1", name: "Apple", description: "green", authorUid: mockUser.id), author: mockUser, priceHistory: []),
        ]
        viewModel.loadProducts()
        XCTAssertEqual(viewModel.filteredProducts.first?.product.description, "green")
        
        mockRepository.updateProduct(Product(id: "1", name: "Apple", description: "red", authorUid: mockUser.id)) { _ in
            
        }
        
        XCTAssertEqual(viewModel.filteredProducts.first?.product.description, "red")
    }
    
    func testCanRemoveItemFromList() {
        mockRepository.mockProductsWithPrices = [
            ProductWithPrices(product: Product(id: "1", name: "Apple", description: "green", authorUid: mockUser.id), author: mockUser, priceHistory: []),
            ProductWithPrices(product: Product(id: "2", name: "Banana", description: "", authorUid: mockUser.id), author: mockUser, priceHistory: [])
        ]
        viewModel.loadProducts()
        viewModel.deleteProduct(atIndex: 0)
        
        XCTAssertEqual(mockRepository.mockProductsWithPrices.count, 1)
        XCTAssertEqual(viewModel.filteredProducts.count, 1)
    }
}
