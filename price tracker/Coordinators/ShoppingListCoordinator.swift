//
//  ShoppingListCoordinator.swift
//  price tracker
//
//  Created by Kris Skierniewski on 05/09/2025.
//

class ShoppingListCoordinator {
    
    private let navigationController: UINavigationController
    private let combinedRepository: CombinedRepositoryProtocol
    
    init(navigationController: UINavigationController, combinedRepository: CombinedRepositoryProtocol) {
        self.navigationController = navigationController
        self.combinedRepository = combinedRepository
    }
    
    func start() {
        let viewModel = ComposeShoppingListViewModel(combinedRepository: combinedRepository)
        
        viewModel.onStartTapped = {
            self.showShoppingListViewController()
        }
        
        viewModel.onError = showErrorAlert(error:)
        
        let viewController = ComposeShoppingListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showShoppingListViewController() {
        let viewModel = ShoppingListViewModel(combinedRepository: combinedRepository)
        
        viewModel.onError = showErrorAlert(error:)
        
        let viewController = ShoppingListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Sorry, something went wrong...", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        navigationController.topViewController?.present(alert, animated: true)
    }
}
