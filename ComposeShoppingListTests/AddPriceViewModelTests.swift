//
//  AddPriceViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

@testable import price_tracker
import XCTest

final class AddPriceViewModelTests: XCTestCase {
    
    var viewModel: AddPriceViewModel!
    var mockRepository: MockCombinedRepository!
    var mockAuthService: MockAuthService!
    var product: ProductWithPrices!
    let mockUser = User(id: "user1", displayName: "User 1")
    
    override func setUpWithError() throws {
        mockAuthService = MockAuthService()
        mockAuthService.mockUserId = mockUser.id
        mockRepository = MockCombinedRepository()
        mockRepository.mockUsers = [mockUser]
        product = ProductWithPrices(product: Product(id: "product1", name: "Apple", description: "", authorUid: mockUser.id), author: mockUser, priceHistory: [])
        mockRepository.mockProductsWithPrices = [product]
        viewModel = AddPriceViewModel(product: product, combinedRepository: mockRepository, authService: mockAuthService)
    }
    
    func testCanAddValidPrice() {
        viewModel.loadShopsAndUnits()
        
        viewModel.setShopName("Lidl")
        viewModel.setPrice(0.99)
        viewModel.setQuantity(500)
        viewModel.selectUnit(.grams)
        viewModel.setNotes("")
        
        viewModel.savePrice()
        
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first?.priceHistory.count, 1)
    }
    
    func testCreatesNewShopIfItDoesNotExist() {
        
        XCTAssertEqual(mockRepository.mockShops.count, 0)
        
        viewModel.loadShopsAndUnits()
        viewModel.setShopName("Lidl")
        viewModel.setPrice(0.99)
        viewModel.setQuantity(500)
        viewModel.selectUnit(.grams)
        viewModel.setNotes("")
        
        viewModel.savePrice()
        
        XCTAssertEqual(mockRepository.mockShops.count, 1)
    }
    
    func testDoesNotCreateNewShopIfItAlreadyExists() {
        mockRepository.mockShops = [Shop(id: "shop1", name: "Lidl")]
        
        viewModel.loadShopsAndUnits()
        XCTAssertEqual(mockRepository.mockShops.count, 1)
        
        viewModel.setShopName("Lidl")
        viewModel.setPrice(0.99)
        viewModel.setQuantity(500)
        viewModel.selectUnit(.grams)
        viewModel.setNotes("")
        
        viewModel.savePrice()
        
        XCTAssertEqual(mockRepository.mockShops.count, 1)
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first?.priceHistory.count, 1)
    }
    
    func testCannotAddPriceWithEmptyShopName() {
        
        var emittedError: Error?
        
        viewModel.onError = {
            emittedError = $0
        }
        
        viewModel.setShopName("")
        viewModel.setPrice(0.99)
        viewModel.setQuantity(500)
        viewModel.selectUnit(.grams)
        viewModel.setNotes("")
        
        viewModel.savePrice()
        
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first?.priceHistory.count, 0)
        XCTAssertEqual(emittedError as? ProductValidationError, .emptyShopName)
    }
    
    func testCannotAddPriceWithEmptyPrice() {
        var emittedError: Error?
        
        viewModel.onError = {
            emittedError = $0
        }
        viewModel.setPrice(nil)
        viewModel.setShopName("Lidl")
        viewModel.setQuantity(500)
        viewModel.selectUnit(.grams)
        viewModel.setNotes("")
        
        viewModel.savePrice()
        
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first?.priceHistory.count, 0)
        XCTAssertEqual(emittedError as? ProductValidationError, .emptyPrice)
    }
    
    func testCannotAddPriceWithEmptyQuantity() {
        var emittedError: Error?
        
        viewModel.onError = {
            emittedError = $0
        }
        viewModel.setPrice(0.99)
        viewModel.setShopName("Lidl")
        viewModel.setQuantity(nil)
        viewModel.selectUnit(.grams)
        viewModel.setNotes("")
        
        viewModel.savePrice()
        
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first?.priceHistory.count, 0)
        XCTAssertEqual(emittedError as? ProductValidationError, .emptyQuantity)
    }
    
    func testCannotAddPriceWithEmptyUnit() {
        var emittedError: Error?
        
        viewModel.onError = {
            emittedError = $0
        }
        viewModel.setPrice(0.99)
        viewModel.setShopName("Lidl")
        viewModel.setQuantity(100)
        viewModel.setNotes("")
        
        viewModel.savePrice()
        
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first?.priceHistory.count, 0)
        XCTAssertEqual(emittedError as? ProductValidationError, .emptyUnit)
    }
    
    // Edit existing price
    func testPopulateFieldsWithExistingPriceForEditing() {
        let shop = Shop(id: "shop1", name: "Aldi")
        let price = Price(productId: product.product.id, price: 0.5, shopId: "shop1", unit: .units, quantity: 3, notes: "", authorUid: mockUser.id)
        let priceWithShop = PriceWithShop(price: price, author: mockUser, shop: shop)
        product.priceHistory.append(priceWithShop)
        
        mockRepository.mockProductsWithPrices = [product]
        
        viewModel = AddPriceViewModel(product: product, existingPrice: priceWithShop, combinedRepository: mockRepository, authService: mockAuthService)
        viewModel.loadShopsAndUnits()
        
        XCTAssertEqual(viewModel.shopName, shop.name)
        XCTAssertEqual(viewModel.price, price.price)
        XCTAssertEqual(viewModel.quantity, price.quantity)
        XCTAssertEqual(viewModel.notes, price.notes)
        XCTAssertEqual(viewModel.unit, price.unit)
    }

    func testEditingExistingPriceDoesNotAddNewPriceRecord() {
        let shop = Shop(id: "shop1", name: "Aldi")
        let price = Price(productId: product.product.id, price: 0.5, shopId: "shop1", unit: .units, quantity: 3, notes: "", authorUid: mockUser.id)
        let priceWithShop = PriceWithShop(price: price, author: mockUser, shop: shop)
        product.priceHistory.append(priceWithShop)
        
        mockRepository.mockProductsWithPrices = [product]
        
        viewModel = AddPriceViewModel(product: product, existingPrice: priceWithShop, combinedRepository: mockRepository, authService: mockAuthService)
        viewModel.loadShopsAndUnits()
        
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first!.priceHistory.count, 1)
        
        viewModel.setPrice(0.8)
        viewModel.savePrice()
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first!.priceHistory.count, 1)
    }
    
}
