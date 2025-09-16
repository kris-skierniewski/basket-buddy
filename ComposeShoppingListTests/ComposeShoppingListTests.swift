//
//  ComposeShoppingListTests.swift
//  ComposeShoppingListTests
//
//  Created by Kris Skierniewski on 28/08/2025.
//

@testable import price_tracker
import XCTest

/*
 add product
 
 filter products by shop
 
 shopping list persists on device or database?
 */

final class ComposeShoppingListTests: XCTestCase {
    
    var mockRepository: MockCombinedRepository!
    var viewModel: ComposeShoppingListViewModel!
    
    let mockUser = User(id: "user1", displayName: "User 1")
    
    var bread: ProductWithPrices!
    var milk: ProductWithPrices!

    override func setUpWithError() throws {
        
        mockRepository = MockCombinedRepository()
        mockRepository.mockUsers = [mockUser]
        
        bread = ProductWithPrices(product: Product(id: "0", name: "Bread", description: "Brown", category: .bakery, authorUid: mockUser.id), author: mockUser,  priceHistory: [])
        milk = ProductWithPrices(product: Product(id: "1", name: "Milk", description: "", category: .dairy, authorUid: mockUser.id), author: mockUser, priceHistory: [])
        mockRepository.mockProductsWithPrices = [bread, milk]
        viewModel = ComposeShoppingListViewModel(combinedRepository: mockRepository)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCanAddProductsToShoppingList() {
        
        viewModel.loadShoppingList()
        
        viewModel.addProduct(bread)
        viewModel.addProduct(milk)
        
        XCTAssertEqual(viewModel.numberOfItems, 2)
        
    }
    
    func testAddedItemsAreGroupedByCategory() {
        
        viewModel.loadShoppingList()
        
        viewModel.addProduct(bread)
        viewModel.addProduct(milk)
        
        XCTAssertEqual(viewModel.sections.count, 2)
        XCTAssertEqual(viewModel.sections.first?.title, "Bakery")
    }
    
    func testAddingProductUpdatesRepository() {
        
        viewModel.loadShoppingList()
        
        viewModel.addProduct(milk)
        
        XCTAssertEqual(mockRepository.mockShoppingList?.products.count, 1)
        
    }
    
    func testCanCleanUpCheckedProducts() {
        
        let mockShoppingList = EnrichedShoppingList(id: "1", products: [
            ShoppingListProduct(productWithPrices: bread, isChecked: true),
            ShoppingListProduct(productWithPrices: milk, isChecked: false)
            
        ])
        mockRepository.mockShoppingList = mockShoppingList
        
        viewModel.loadShoppingList()
        
        viewModel.cleanUp()
        
        XCTAssertEqual(viewModel.numberOfItems, 1)
        XCTAssertEqual(viewModel.sections[0].products[0].productWithPrices.product.name, "Milk")
        
    }
    
    
    

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
