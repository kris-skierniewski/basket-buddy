//
//  SelectDatasetViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 12/09/2025.
//

@testable import price_tracker
import XCTest

class SelectDatasetViewModelTests: XCTestCase {
    
    var mockRepository: MockDatasetRepository!
    var mockInviteService: MockInviteService!
    var mockAuthService: MockAuthService!
    var viewModel: SelectDatasetViewModel!
    
    override func setUpWithError() throws {
        mockRepository = MockDatasetRepository()
        mockAuthService = MockAuthService()
        mockInviteService = MockInviteService()
        viewModel = SelectDatasetViewModel(authService: mockAuthService, datasetRepository: mockRepository, inviteService: mockInviteService)
    }
    
    
    
}
