//
//  CreateAccountViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

@testable import price_tracker
import XCTest

final class CreateAccountViewModelTests: XCTestCase {
    
    var mockAuthService: MockAuthService!
    var mockUserRepository: MockUserRepository!
    
    var viewModel: CreateAccountViewModel!
    
    override func setUpWithError() throws {
        mockAuthService = MockAuthService()
        mockUserRepository = MockUserRepository()
        viewModel = CreateAccountViewModel(authService: mockAuthService, userRepository: mockUserRepository)
    }
    
    func testCanRegisterWithValidCredentials() {
        var didSucceed = false
        
        viewModel.displayName = "Test user"
        viewModel.emailAddress = "test@test.com"
        viewModel.password = "password"
        viewModel.confirmPassword = "password"
        
        viewModel.onSuccess = {
            didSucceed = true
        }
        
        viewModel.createAccount()
        
        XCTAssertTrue(didSucceed)
    }
    
    func testRegisterFailsIfEmailAddressIsEmpty() {
        var emittedError: Error?
        
        viewModel.emailAddress = ""
        
        viewModel.onError = { error in
            emittedError = error
        }
        
        viewModel.createAccount()
        XCTAssertEqual(emittedError as? AuthenticationError, .emptyEmailAddress)
    }
    
    func testRegisterFailsIfPasswordIsEmpty() {
        var emittedError: Error?
        
        viewModel.emailAddress = "test@email.com"
        viewModel.displayName = "Test user"
        
        viewModel.onError = { error in
            emittedError = error
        }
        
        viewModel.createAccount()
        XCTAssertEqual(emittedError as? AuthenticationError, .emptyPassword)
    }
    
    func testRegisterFailsIfPasswordsDontMatch() {
        var emittedError: Error?
        
        viewModel.displayName = "Test user"
        viewModel.emailAddress = "test@email.com"
        viewModel.password = "test"
        
        viewModel.onError = { error in
            emittedError = error
        }
        
        viewModel.createAccount()
        XCTAssertEqual(emittedError as? AuthenticationError, .passwordsDontMatch)
    }
    
}
