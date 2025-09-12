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
    var viewModel: SelectDatasetViewModel!
    
    override func setUpWithError() throws {
        mockRepository = MockDatasetRepository()
        mockInviteService = MockInviteService()
        viewModel = SelectDatasetViewModel(datasetRepository: mockRepository, inviteService: mockInviteService)
    }
    
    
    
}
