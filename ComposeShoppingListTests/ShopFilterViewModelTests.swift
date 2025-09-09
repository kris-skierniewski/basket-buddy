//
//  ShoppingListViewModelTests 2.swift
//  price tracker
//
//  Created by Kris Skierniewski on 09/09/2025.
//


@testable import price_tracker
import XCTest

final class ShopFilterViewModelTests: XCTestCase {
    
    var mockRepository: MockCombinedRepository!
    var viewModel: ShopFilterViewModel!
    
    let tesco = Shop(id: "1", name: "Tesco")
    let asda = Shop(id: "2", name: "Asda")
    
    override func setUpWithError() throws  {
        
        mockRepository = MockCombinedRepository()
        viewModel = ShopFilterViewModel(combinedRepository: mockRepository, selectedFilter: .all)
    }
    
    func testShowsFiltersForAllShopsAndNone() {
        mockRepository.mockShops = [tesco, asda]
        
        viewModel.loadShops()
        
        XCTAssertEqual(viewModel.sections.count, 1)
        //1 for each shop and 1 for all shops
        XCTAssertEqual(viewModel.sections.first?.items.count, 3)
    }
    
}
