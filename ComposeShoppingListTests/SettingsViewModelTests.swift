//
//  SettingsViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

@testable import price_tracker
import XCTest

final class SettingsViewModelTests: XCTestCase {
    
    var mockAuthService: MockAuthService!
    var mockRepository: MockCombinedRepository!
    var viewModel: AccountViewModel!
    
    let mockUser = User(id: "mockUser1", displayName: "Test user")
    
    override func setUpWithError() throws {
        mockRepository = MockCombinedRepository()
        mockRepository.mockUsers = [mockUser]
        mockAuthService = MockAuthService()
        mockAuthService.mockUserId = mockUser.id
        viewModel = AccountViewModel(authService: mockAuthService, combinedRepository: mockRepository)
    }
    
    func testSignOutCallsAuthService() {
        viewModel.signOut()
        XCTAssertEqual(mockAuthService.numberOfTimesSignOutCalled, 1)
    }
    
    func testDisplaysEmailAddressFromAuthService() {
        mockAuthService.mockUserEmailAddress = "test@example.com"
        
        viewModel.loadUser()
        XCTAssertEqual(viewModel.emailAddress, "test@example.com")
    }
    
}
