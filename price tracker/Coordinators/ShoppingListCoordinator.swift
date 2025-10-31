//
//  ShoppingListCoordinator.swift
//  price tracker
//
//  Created by Kris Skierniewski on 05/09/2025.
//

class ShoppingListCoordinator {
    
    private let navigationController: UINavigationController
    private let combinedRepository: CombinedRepositoryProtocol
    private let inviteService: InviteServiceProtocol
    private let authService: AuthService
    private let datasetId: String
    private let datasetRepository: DatasetRepository
    
    private let productCoordinator: ProductCoordinator //child coordinator
    
    init(navigationController: UINavigationController,
         combinedRepository: CombinedRepositoryProtocol,
         inviteService: InviteServiceProtocol,
         authService: AuthService,
         datasetRepository: DatasetRepository,
         datasetId: String) {
        self.navigationController = navigationController
        self.combinedRepository = combinedRepository
        self.inviteService = inviteService
        self.authService = authService
        self.datasetRepository = datasetRepository
        self.datasetId = datasetId
        self.productCoordinator = ProductCoordinator(navigationController: navigationController,
                                                     datasetId: datasetId,
                                                     datasetRepository: datasetRepository,
                                                     combinedRepository: combinedRepository,
                                                     inviteService: inviteService,
                                                     authService: authService)
    }
    
    func start() {
        let viewModel = ComposeShoppingListViewModel(combinedRepository: combinedRepository)
        
        viewModel.onStartTapped = {
            self.showShoppingListViewController()
        }
        
        viewModel.onAddProductButtonTapped = showAddProductViewController
        viewModel.onProductTapped = showProductDetailViewController(product:)
        viewModel.onSetQuantityTapped = showSetQuantityViewController(for:)
        
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
        let viewModel = SearchProductsViewModel(combinedRepository: combinedRepository, authService: authService)
        
        let viewController = SearchProductsViewController(viewModel: viewModel)
        
        viewModel.onCompleted = {
            viewController.dismiss(animated: true)
        }
        viewModel.onError = showErrorAlert(error:)
        
        let addProductNav = UINavigationController(rootViewController: viewController)
        addProductNav.modalPresentationStyle = .fullScreen
        navigationController.present(addProductNav, animated: true)
    }
    
    private func showSetQuantityViewController(for product: ShoppingListProduct) {
        let viewModel = SetQuantityViewModel(combinedRepository: combinedRepository, shoppingListProduct: product)
        let viewController = SetQuantityViewController(viewModel: viewModel)
        viewModel.onSuccess = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        viewModel.onError = showErrorAlert(error:)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showProductDetailViewController(product: ProductWithPrices) {
        productCoordinator.showProductDetail(product)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Sorry, something went wrong...", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        navigationController.topViewController?.present(alert, animated: true)
    }
}
