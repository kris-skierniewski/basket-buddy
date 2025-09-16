//
//  ProductDetailViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

@testable import price_tracker
import XCTest

final class ProductDetailViewModelTests: XCTestCase {
    
    var viewModel: ProductDetailViewModel!
    var mockRepository: MockCombinedRepository!
    var productWithPrices: ProductWithPrices!
    
    let mockUser = User(id: "user1", displayName: "User 1")
    
    var price1: Price!
    var price2: Price!
    var price3: Price!
    
    override func setUpWithError() throws {
        mockRepository = MockCombinedRepository()
        mockRepository.mockUsers = [mockUser]
        
        let product = Product(id: "product1", name: "Apple", description: "red", authorUid: mockUser.id)
        let shop = Shop(id: "shop1", name: "Tesco")
        price1 = Price(productId: "product1", price: 0.5, shopId: "shop1", unit: .units, quantity: 1, notes: "")
        price2 = Price(productId: "product1", price: 0.9, shopId: "shop1", unit: .units, quantity: 1, notes: "")
        price3 = Price(productId: "product1", price: 0.7, shopId: "shop1", unit: .units, quantity: 1, notes: "")
        
        productWithPrices = ProductWithPrices(product: product, author: mockUser, priceHistory: [
            PriceWithShop(price: price1, shop: shop),
            PriceWithShop(price: price2, shop: shop),
            PriceWithShop(price: price3, shop: shop)])
        
        mockRepository.mockProductsWithPrices = [productWithPrices]
        
        viewModel = ProductDetailViewModel(product: productWithPrices, combinedRepository: mockRepository)
    }
    
    
    
    func testPricesSortedWithMostRecentFirst() {
        
        viewModel.loadProduct()
        XCTAssertTrue(viewModel.prices.first!.price.timestamp > viewModel.prices.last!.price.timestamp)
    }
    
    func testCanRemovePriceAtValidIndex() {
        viewModel.loadProduct()
        viewModel.removePrice(at: 1)
        XCTAssertEqual(viewModel.prices.count, 2)
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first?.priceHistory.count, 2)
    }
    
    func testCannotRemovePriceAtInvalidIndex() {
        
        var emittedError: Error?
        
        viewModel.onError = {
            emittedError = $0
        }
        
        viewModel.loadProduct()
        viewModel.removePrice(at: 100)
        XCTAssertEqual(viewModel.prices.count, 3)
        XCTAssertEqual(mockRepository.mockProductsWithPrices.first?.priceHistory.count, 3)
        XCTAssertEqual(emittedError as? RepositoryError, .invalidIndex)
    }
    
}
