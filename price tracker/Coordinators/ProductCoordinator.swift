//
//  ProductCoordinator.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

class ProductCoordinator {
    private let navigationController: UINavigationController
    private let combinedRepository: CombinedRepositoryProtocol
    private let inviteService: InviteServiceProtocol
    private let authService: AuthService
    
    private var productTableViewModel: ProductTableViewModel?
    
    init(navigationController: UINavigationController,
         combinedRepository: CombinedRepositoryProtocol,
         inviteService: InviteServiceProtocol,
         authService: AuthService) {
        self.navigationController = navigationController
        self.combinedRepository = combinedRepository
        self.inviteService = inviteService
        self.authService = authService
    }
    
    func start() {
        productTableViewModel = ProductTableViewModel(combinedRepository: combinedRepository)
        let productTableViewController = ProductTableViewController(viewModel: productTableViewModel!)
        
        productTableViewModel?.onProductSelected = { product in
            self.showProductDetail(product)
        }
        
        productTableViewModel?.onError = { error in
            self.showErrorAlert(error: error)
        }
        
        productTableViewModel?.onAddProductButtonTapped = { searchString in
            self.showAddProductViewController(searchString: searchString)
        }
        
        productTableViewModel?.onShopFilterButtonTapped = { filter in
            self.showShopFiltersViewController(selectedFilter: filter)
        }
        
        productTableViewModel?.onShareTapped = showShareFlow(sourceView:)
        
        navigationController.pushViewController(productTableViewController, animated: false)
    }
    
    func showProductDetail(_ product: ProductWithPrices) {
        
        let productDetailViewModel = ProductDetailViewModel(product: product, combinedRepository: combinedRepository)
        
        productDetailViewModel.onAddPriceButtonTapped = {
            self.showAddPriceViewController(for: product)
        }
        productDetailViewModel.onEditPriceButtonTapped = { price in
            self.showEditPriceViewController(for: product, price: price)
        }
        productDetailViewModel.onEditProductButtonTapped = { product in
            self.showEditProductViewController(for: product)
        }
        productDetailViewModel.onError = { error in
            self.showErrorAlert(error: error)
        }
        
        let productDetailViewController = ProductDetailViewController(viewModel: productDetailViewModel)
        navigationController.pushViewController(productDetailViewController, animated: true)
    }
    
    private func showAddPriceViewController(for product: ProductWithPrices) {
        
        let priceCoordinator = PriceCoordinator(navigationController: navigationController, combinedRepository: combinedRepository, product: product)
        priceCoordinator.start()
        
    }
    
    private func showEditPriceViewController(for product: ProductWithPrices, price: PriceWithShop) {
        let priceCoordinator = PriceCoordinator(navigationController: navigationController, combinedRepository: combinedRepository, product: product)
        priceCoordinator.start(existingPrice: price)
    }
    
    private func showAddProductViewController(searchString: String?) {
        let viewModel = AddProductViewModel(searchString: searchString, combinedRepository: combinedRepository, authService: authService)
        
        viewModel.onSuccess = {
            self.navigationController.popViewController(animated: true)
        }
        viewModel.onCancel = {
            self.navigationController.popViewController(animated: true)
        }
        viewModel.onError = { error in
            self.showErrorAlert(error: error)
        }
        
        let viewController = AddProductViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showEditProductViewController(for product: ProductWithPrices) {
        let viewModel = AddProductViewModel(withExistingProduct: product.product, combinedRepository: combinedRepository, authService: authService)
        
        viewModel.onSuccess = {
            self.navigationController.popViewController(animated: true)
        }
        viewModel.onCancel = {
            self.navigationController.popViewController(animated: true)
        }
        viewModel.onError = { error in
            self.showErrorAlert(error: error)
        }
        
        let viewController = AddProductViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showShopFiltersViewController(selectedFilter: ShopFilter) {
        let viewModel = ShopFilterViewModel(combinedRepository: combinedRepository, selectedFilter: selectedFilter)
        
        viewModel.onDismiss = { filter in
            self.productTableViewModel?.setShopFilter(filter)
        }
        
        let viewController = ShopFilterViewController(viewModel: viewModel)
        let shopFiltersNav = UINavigationController(rootViewController: viewController)
        navigationController.topViewController?.present(shopFiltersNav, animated: true)
    }
    
    private func showShareFlow(sourceView: UIBarButtonItem) {
        
        inviteService.createInvite() { [weak self] result in
            switch result {
            case .success(let invite):
                
                
                let activityViewController = UIActivityViewController(
                    activityItems: [invite],
                    applicationActivities: nil
                )
                
//                 For iPad - required to prevent crash
                if let popover = activityViewController.popoverPresentationController {
                    popover.sourceItem = sourceView
                    popover.permittedArrowDirections = [.any]
                }
                self?.navigationController.topViewController?.present(activityViewController, animated: true)
                
                
            case .failure(let error):
                self?.showErrorAlert(error: error)
            }
        }
        
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Sorry, something went wrong...", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        navigationController.topViewController?.present(alert, animated: true)
    }
    
    deinit {
        print("deiniting product coordinator")
    }

}
