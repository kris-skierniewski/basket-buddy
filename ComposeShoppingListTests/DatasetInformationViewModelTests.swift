//
//  DatasetInformationViewModelTests.swift
//  price tracker
//
//  Created by Kris Skierniewski on 16/09/2025.
//
@testable import price_tracker
import XCTest

class DatasetInformationViewModelTests: XCTestCase {
    
    var mockCombinedRepository: MockCombinedRepository!
    var mockDatasetRepository: MockDatasetRepository!
    var mockAuthService: MockAuthService!
    var viewModel: DatasetInformationViewModel!
    
    let mockUsers = [User(id: "user1", displayName: "User 1"), User(id: "user2", displayName: "User 2")]
    
    var mockDataset: Dataset!
    
    override func setUpWithError() throws {
        mockAuthService = MockAuthService()
        mockAuthService.mockUserId = "user1"
        
        mockCombinedRepository = MockCombinedRepository()
        mockCombinedRepository.mockUsers = mockUsers
        
        mockDataset = Dataset(id: "dataset1", members: [
            mockUsers[0].id: true,
            mockUsers[1].id: true
        ])
        
        mockDatasetRepository = MockDatasetRepository()
        mockDatasetRepository.mockDatasets = [mockDataset]
        
        
        viewModel = DatasetInformationViewModel(datasetId: mockDataset.id, combinedRepository: mockCombinedRepository, datasetRepository: mockDatasetRepository, authService: mockAuthService)
    }
    
    func testLoadDatasetMembers() {
        viewModel.loadDatasetInformation()
        
        XCTAssertEqual(viewModel.rows.count, 2)
    }
}
