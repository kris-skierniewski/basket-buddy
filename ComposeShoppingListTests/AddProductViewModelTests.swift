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
    
    override func setUpWithError() throws {
        mockRepository = MockCombinedRepository()
        viewModel = AddProductViewModel(combinedRepository: mockRepository)
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
        
        let existingProduct = Product(id: "1", name: "Apple", description: "green")
        mockRepository.mockProductsWithPrices = [ProductWithPrices(product: existingProduct, priceHistory: [])]
        
        viewModel = AddProductViewModel(withExistingProduct: existingProduct, combinedRepository: mockRepository)
        
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
