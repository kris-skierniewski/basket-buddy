//
//  AccountViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

@testable import price_tracker
import XCTest

final class AccountViewModelTests: XCTestCase {
    
    var mockAuthService: MockAuthService!
    var mockRepository: MockCombinedRepository!
    var viewModel: AccountViewModel!
    
    
    override func setUpWithError() throws {
        mockRepository = MockCombinedRepository()
        mockAuthService = MockAuthService()
        viewModel = AccountViewModel(authService: mockAuthService, combinedRepository: mockRepository)
    }
    
    func testSignOutCallsAuthService() {
        viewModel.signOut()
        XCTAssertEqual(mockAuthService.numberOfTimesSignOutCalled, 1)
    }
    
    func deleteAccountRemovesAllProducts() {
        mockRepository.mockProductsWithPrices = [
            ProductWithPrices(product: Product(id: "id", name: "Test product", description: ""),
                              priceHistory: [])]
        
        viewModel.deleteAccount()
        XCTAssertEqual(mockRepository.mockProductsWithPrices.count, 0)
    }
    
    func deleteAccountRemovesAllShops() {
        mockRepository.mockShops = [Shop(id: "id", name: "Test")]
        
        viewModel.deleteAccount()
        XCTAssertEqual(mockRepository.mockShops.count, 0)
    }
    
    func deleteAccountRemovesAllPreferences() {
        
    }
    
    func testDeleteAccountCallsAuthService() {
        viewModel.deleteAccount()
        XCTAssertEqual(mockAuthService.numberOfTimesDeleteUserCalled, 1)
    }
    
    func testDisplaysEmailAddressFromAuthService() {
        mockAuthService.mockUserEmailAddress = "test@example.com"
        
        viewModel.loadUser()
        XCTAssertEqual(viewModel.emailAddress, "test@example.com")
    }
    
    func testCanSetCurrencyPreference() {
        mockRepository.mockUserPreferences?.currency = .eur
        
        viewModel.loadUser()
        
        viewModel.setCurrencyPreference(Currency.gbp)
        
        XCTAssertEqual(viewModel.currency, Currency.gbp)
        XCTAssertEqual(mockRepository.mockUserPreferences?.currency, .gbp)
        
    }
    
    
}
