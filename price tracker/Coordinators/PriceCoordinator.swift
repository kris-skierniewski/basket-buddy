//
//  PriceCoordinator.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//
//
class PriceCoordinator {
    
    private let navigationController: UINavigationController
    private let combinedRepository: CombinedRepositoryProtocol
    private var product: ProductWithPrices
    
    
    private var addPriceViewModel: AddPriceViewModel?
    private var addPriceViewController: AddPriceViewController?
    
    init(navigationController: UINavigationController, combinedRepository: CombinedRepositoryProtocol, product: ProductWithPrices) {
        self.navigationController = navigationController
        self.combinedRepository = combinedRepository
        self.product = product
    }
    
    func start(existingPrice: PriceWithShop? = nil) {
        
        let addPriceViewModel = AddPriceViewModel(product: product, existingPrice: existingPrice, combinedRepository: combinedRepository)
        
        addPriceViewModel.onSuccess = {
            self.navigationController.popViewController(animated: true)
        }
        
        addPriceViewModel.onError = { error in
            self.showErrorAlert(error: error)
        }
        
        addPriceViewController = AddPriceViewController(viewModel: addPriceViewModel)
        navigationController.pushViewController(addPriceViewController!, animated: true)
        
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Sorry, something went wrong...", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        navigationController.topViewController?.present(alert, animated: true)
    }

}
