//
//  SignInViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

@testable import price_tracker
import XCTest

final class SignInViewModelTests: XCTestCase {
    
    var mockAuthService: MockAuthService!
    var viewModel: SignInViewModel!
    
    override func setUpWithError() throws {
        mockAuthService = MockAuthService()
        viewModel = SignInViewModel(authService: mockAuthService)
    }
    
    func testSignInWithValidCredentials() {
        
        var didSucceed = false
        
        viewModel.emailAddress = "test@example.com"
        viewModel.password = "password1"
        
        viewModel.onSignInSuccess = {
            didSucceed = true
        }
        
        viewModel.signIn()
        
        XCTAssertTrue(didSucceed)
    }
    
    func testCanResetPassword() {
        var didSucceed = false
        viewModel.emailAddress = "test@example.com"
        
        viewModel.onResetPasswordSuccess = {
            didSucceed = true
        }
        
        viewModel.sendPasswordReset()
        
        XCTAssertTrue(didSucceed)
    }
}
