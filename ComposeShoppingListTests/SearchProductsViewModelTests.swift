//
//  SearchProductsViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 09/09/2025.
//

@testable import price_tracker
import XCTest

class SearchProductsViewModelTests: XCTestCase {
    
    var mockCombinedRepository: MockCombinedRepository!
    var mockAuthService: MockAuthService!
    var viewModel: SearchProductsViewModel!
    
    let mockUser = User(id: "user1", displayName: "User 1")
    
    var apple: ProductWithPrices!
    var rice: ProductWithPrices!
    
    override func setUpWithError() throws {
        mockAuthService = MockAuthService()
        mockAuthService.mockUserId = mockUser.id
        mockCombinedRepository = MockCombinedRepository()
        mockCombinedRepository.mockUsers = [mockUser]
        mockCombinedRepository.mockLoggedInUser = mockUser
        viewModel = SearchProductsViewModel(combinedRepository: mockCombinedRepository, authService: mockAuthService)
        
        apple = ProductWithPrices(product: Product(id: "0", name: "Apple", description: "", authorUid: mockUser.id), author: mockUser, priceHistory: [])
        rice = ProductWithPrices(product: Product(id: "1", name: "Rice", description: "", authorUid: mockUser.id), author: mockUser, priceHistory: [])
    }
    
    func testCanSearchExistingProducts() {
        mockCombinedRepository.mockProductsWithPrices = [apple, rice]
        
        viewModel.loadProducts()
        
        XCTAssertEqual(viewModel.rows.count, 2)
        
        viewModel.search("Apple")
        
        XCTAssertEqual(viewModel.rows.count, 1)
        XCTAssertEqual(viewModel.rows.first?.product.product.name, "Apple")
    }
    
    func testDisplaysRowForNewItemIfNotFound() {
        mockCombinedRepository.mockProductsWithPrices = [apple, rice]
        
        viewModel.loadProducts()
        
        XCTAssertEqual(viewModel.rows.count, 2)
        
        viewModel.search("Milk")
        
        XCTAssertEqual(viewModel.rows.count, 1)
        XCTAssertEqual(viewModel.rows.first?.product.product.name, "Milk")
        XCTAssertFalse(viewModel.rows.first!.exists)
    }
    
    func testAddsNewItemToRepositoryIfSearchedForAndNotFound() {
        mockCombinedRepository.mockProductsWithPrices = [apple, rice]
        
        viewModel.loadProducts()
        
        viewModel.search("Milk")
        
        viewModel.select(row: 0)
        
        XCTAssertEqual(mockCombinedRepository.mockProductsWithPrices.count, 3)
    }
    
    func testAddNewItemToShoppingListWhenSelected() {
        mockCombinedRepository.mockProductsWithPrices = [apple, rice]
        
        viewModel.loadProducts()
        
        viewModel.search("Milk")
        
        viewModel.select(row: 0)
        
        XCTAssertEqual(mockCombinedRepository.mockShoppingList?.products.count, 1)
        XCTAssertEqual(mockCombinedRepository.mockShoppingList?.products.first?.productWithPrices.product.name, "Milk")
    }
    
    func testAddExistingItemToShoppingListWhenSelected() {
        mockCombinedRepository.mockProductsWithPrices = [apple, rice]
        
        viewModel.loadProducts()
        
        viewModel.search("App")
        
        viewModel.select(row: 0)
        
        XCTAssertEqual(mockCombinedRepository.mockShoppingList?.products.count, 1)
        XCTAssertEqual(mockCombinedRepository.mockShoppingList?.products.first?.productWithPrices.product.name, "Apple")
    }
    
}
