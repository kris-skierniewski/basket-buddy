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
        
        viewModel.onAddProductButtonTapped = showAddProductViewController
        
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
    
    private func showAddProductViewController() {
        let viewModel = SearchProductsViewModel(combinedRepository: combinedRepository)
        
        let viewController = SearchProductsViewController(viewModel: viewModel)
        
        viewModel.onCompleted = {
            viewController.dismiss(animated: true)
        }
        viewModel.onError = showErrorAlert(error:)
        
        let addProductNav = UINavigationController(rootViewController: viewController)
        addProductNav.modalPresentationStyle = .fullScreen
        navigationController.present(addProductNav, animated: true)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Sorry, something went wrong...", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        navigationController.topViewController?.present(alert, animated: true)
    }
}
