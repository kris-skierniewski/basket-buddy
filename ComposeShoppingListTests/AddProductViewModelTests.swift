//
//  AddProductViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

@testable import price_tracker
import XCTest

final class AddProductViewModelTests: XCTestCase {
    
    var viewModel: AddProductViewModel!
    var mockRepository: MockCombinedRepository!
    var mockAuthService: MockAuthService!
    
    let mockUser = User(id: "user1", displayName: "User 1")
    
    override func setUpWithError() throws {
        mockAuthService = MockAuthService()
        mockAuthService.mockUserId = mockUser.id
        mockRepository = MockCombinedRepository()
        mockRepository.mockUsers = [mockUser]
        viewModel = AddProductViewModel(combinedRepository: mockRepository, authService: mockAuthService)
    }
    
    func testCanAddProductWithValidNameAndDescription() {
        
        let name = "Apple"
        let description = "Red"
        
        var didSucceed = false
        
        viewModel.onSuccess = {
            didSucceed = true
        }
        
        viewModel.setName(name)
        viewModel.setDescription(description)
        viewModel.saveProduct()
        
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first?.product.name, name)
        XCTAssertTrue(didSucceed)
    }
    
    func testInvalidNameDoesNotAddProductAndEmitsError() {
        let name = ""
        let description = "Red"
        
        var didFail = false
        var emittedError: Error?
        
        viewModel.onError = { error in
            didFail = true
            emittedError = error
        }
        
        viewModel.setName(name)
        viewModel.setDescription(description)
        viewModel.saveProduct()
        
        XCTAssertEqual(mockRepository.mockProductsWithPrices.count, 0)
        XCTAssertTrue(didFail)
        XCTAssertEqual(emittedError as? ProductValidationError, .emptyName)
    }
    
    func testCanUpdateExistingProduct() {
        
        let existingProduct = Product(id: "1", name: "Apple", description: "green", authorUid: mockUser.id)
        mockRepository.mockProductsWithPrices = [ProductWithPrices(product: existingProduct, author: mockUser, priceHistory: [])]
        
        viewModel = AddProductViewModel(withExistingProduct: existingProduct, combinedRepository: mockRepository, authService: mockAuthService)
        
        var didSucceed = false
        viewModel.onSuccess = {
            didSucceed = true
        }
        
        viewModel.populateTextFields()
        viewModel.setDescription("red")
        viewModel.saveProduct()
        
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first?.product.description, "red")
        XCTAssertTrue(didSucceed)
        
    }
    
    
}
