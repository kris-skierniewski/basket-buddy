//
//  ShoppingListViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 08/09/2025.
//

@testable import price_tracker
import XCTest

final class ShoppingListViewModelTests: XCTestCase {
    
    var mockRepository: MockCombinedRepository!
    var viewModel: ShoppingListViewModel!
    let mockUser = User(id: "user1", displayName: "User 1")
    
    var bread: ProductWithPrices!
    var milk: ProductWithPrices!
    var rice: ProductWithPrices!
    
    
    override func setUpWithError() throws {
        
        mockRepository = MockCombinedRepository()
        mockRepository.mockUsers = [mockUser]
        
        bread = ProductWithPrices(product: Product(id: "0", name: "Bread", description: "Brown", category: .bakery, authorUid: mockUser.id), author: mockUser, priceHistory: [])
        milk = ProductWithPrices(product: Product(id: "1", name: "Milk", description: "", category: .dairy, authorUid: mockUser.id), author: mockUser, priceHistory: [])
        rice = ProductWithPrices(product: Product(id: "2", name: "Rice", description: "", category: .grains, authorUid: mockUser.id), author: mockUser, priceHistory: [])
        
        mockRepository.mockProductsWithPrices = [bread, milk, rice]
        mockRepository.mockShoppingList = EnrichedShoppingList(id: "shoppingList1", products: [
            ShoppingListProduct(productWithPrices: bread, isChecked: false),
            ShoppingListProduct(productWithPrices: milk, isChecked: false),
            ShoppingListProduct(productWithPrices: rice, isChecked: false)
        ])
        viewModel = ShoppingListViewModel(combinedRepository: mockRepository)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testCanMarkItemAsCompleted() {
        
        viewModel.loadShoppingList()
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        viewModel.markCompleted(completed: true, atIndexPath: indexPath)
        
        let completedSection = viewModel.sections.last
        
        let completedSectionContainsBread = completedSection?.products.contains(where: { $0.productWithPrices.product.id == "0" }) ?? false
        
        XCTAssertTrue(completedSectionContainsBread)
        
    }
    
    func testCantMarkItemAsCompletedIfIndexIsInvalud() {
        
        var emittedError: Error?
        viewModel.onError = {
            emittedError = $0
        }
        
        viewModel.loadShoppingList()
        
        let indexPath = IndexPath(row: 5, section: 0)
        
        viewModel.markCompleted(completed: true, atIndexPath: indexPath)
        
        XCTAssertEqual(emittedError as? RepositoryError, .invalidIndex)
        
    }
    
}
