//
//  AppCoordinator.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

import FirebaseAuth
import SafariServices

class AppCoordinator {
    private let window: UIWindow
    
    private var authStateHandle: AuthStateHandle?
    private var authService: AuthService
    
    private let onboardingManager = OnboardingManager.shared
    
    private var inviteService: FirebaseInviteService?
    private var datasetRepository: FirebaseDatasetRepository?
    private var userDatasetIdHandle: ObserverHandle?
    private var datasetHandle: ObserverHandle?
    
    var currentUserId: String? {
        return authService.currentUserId
    }
    
    init(window: UIWindow) {
        self.window = window
        self.authService = FirebaseAuthService()
    }
    
    func start() {
        
        authStateHandle = authService.addStateDidChangeListener {
            if self.currentUserId != nil {
                self.showDatasetLoadingFlow()
            } else {
                self.showAuthFlow()
            }
            self.showOnbordingIfNeeded()
        }
    }
    
    private var userDatasetId: String?
    private var dataset: Dataset?
    
    private func showDatasetLoadingFlow() {
        
        let firebaseDatabaseService = FirebaseDatabaseService()
        datasetRepository = FirebaseDatasetRepository(firebaseService: firebaseDatabaseService, userId: currentUserId!)
        inviteService = FirebaseInviteService(databaseService: firebaseDatabaseService, datasetRepository: datasetRepository!, authService: authService)
        
        datasetRepository?.getUserDatasetId { [weak self] result in
            switch result {
            case .success(let datasetId):
                if let datasetId = datasetId {
                    self?.userDatasetId = datasetId
                    self?.observeUserDatasetId()
                    self?.getDataset(withId: datasetId)
                } else {
                    self?.showSelectDatasetFlow()
//                    self?.datasetRepository?.setupUserDataset { result in
//                        switch result {
//                        case .success(let datasetId):
//                            self?.getDataset(withId: datasetId)
//                        case .failure(let error):
//                            self?.showErrorAlert(error: error)
//                        }
//                    }
                }
            case .failure(let error):
                self?.showErrorAlert(error: error)
            }
        }
        
        let loadingViewController = LoadingViewController()
        window.rootViewController = loadingViewController
        window.makeKeyAndVisible()
    }
    
    private func showSelectDatasetFlow() {
        guard let datasetRepository = datasetRepository, let inviteService = inviteService else {
            return
        }
        let viewModel = SelectDatasetViewModel(datasetRepository: datasetRepository, inviteService: inviteService)
        viewModel.onSuccess = { [weak self] in
            self?.showDatasetLoadingFlow()
        }
        let viewController = SelectDatasetViewController(viewModel: viewModel)
        
        window.rootViewController = viewController
    }
    
    private func observeUserDatasetId() {
        datasetHandle?.remove()
        userDatasetIdHandle?.remove()
        userDatasetIdHandle = datasetRepository?.observeUserDatasetId(onChange: { [weak self] updatedDatasetId in
            if let updatedDatasetId = updatedDatasetId,
               updatedDatasetId != self?.userDatasetId {
                self?.userDatasetId = updatedDatasetId
                self?.getDataset(withId: updatedDatasetId)
            }
            
        })
    }
    
    private func getDataset(withId datasetId: String) {
        datasetRepository?.getDataset(withId: datasetId) { [weak self] result in
            switch result {
            case .success(let dataset):
                if let dataset = dataset {
                    self?.dataset = dataset
                    self?.observeDataSet(withId: datasetId)
                    self?.showMainFlow(forDataset: dataset)
                } else {
                    guard let currentUserId = self?.currentUserId else {
                        return
                    }
                    let newDataset = Dataset(id: datasetId, members: [currentUserId: true])
                    self?.datasetRepository?.updateDataset(newDataset) { result in
                        switch result {
                        case .success():
                            self?.observeDataSet(withId: datasetId)
                        case .failure(let error):
                            self?.showErrorAlert(error: error)
                        }
                    }
                }
            case .failure(let error):
                self?.showErrorAlert(error: error)
            }
        }
        
    }
    
    private func observeDataSet(withId datasetId: String) {
        datasetHandle?.remove()
        datasetHandle = datasetRepository?.observeDataset(withId: datasetId, onChange: { [weak self] updatedDataset in
            if let updatedDataset = updatedDataset,
               updatedDataset != self?.dataset {
                self?.dataset = updatedDataset
                self?.showMainFlow(forDataset: updatedDataset)
            }
        })
        
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Sorry, something went wrong...", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        window.rootViewController?.present(alert, animated: true)
    }
    
    private func showMainFlow(forDataset dataset: Dataset) {
        
        let firebaseDatabaseService = FirebaseDatabaseService()
        let productRepository = FirebaseProductRepository(firebaseService: firebaseDatabaseService, datasetId: dataset.id)
        let shopRepository = FirebaseShopRepository(firebaseService: firebaseDatabaseService, datasetId: dataset.id)
        let priceRepository = FirebasePriceRepository(firebaseService: firebaseDatabaseService, datasetId: dataset.id)
        let userPreferencesRepository = FirebaseUserPreferenceRepository(firebaseService: firebaseDatabaseService, datasetId: dataset.id)
        let shoppingListRepository = FirebaseShoppingListRepository(firebaseService: firebaseDatabaseService, datasetId: dataset.id)
        let combinedRepository = CombinedRepository(productRepository: productRepository, shopRepository: shopRepository, priceRepository: priceRepository, userPreferencesRepository: userPreferencesRepository, shoppingListRepository: shoppingListRepository)
        
        let tabBarController = UITabBarController()
        
        let productTableNav = UINavigationController()
        let productCoordinator = ProductCoordinator(navigationController: productTableNav,
                                                    combinedRepository: combinedRepository,
                                                    inviteService: inviteService!)
        productCoordinator.start()
        
        let shoppingListNav = UINavigationController()
        let shoppingListCoordinator = ShoppingListCoordinator(navigationController: shoppingListNav,
                                                              combinedRepository: combinedRepository,
                                                              inviteService: inviteService!)
        shoppingListCoordinator.start()
        
        let accountNav = UINavigationController()
        let accountCoordinator = AccountCoordinator(navigationController: accountNav, combinedRepository: combinedRepository, authService: authService)
        accountCoordinator.start()
        
        productTableNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        shoppingListNav.tabBarItem = UITabBarItem(title: "Shopping List", image: UIImage(systemName: "cart"), tag: 1)
        accountNav.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.crop.circle"), tag: 2)
        tabBarController.viewControllers = [productTableNav, shoppingListNav, accountNav]
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func showAuthFlow() {
        let authNavController = UINavigationController()
        let authCoordinator = AuthCoordinator(navigationController: authNavController, authService: authService)
        authCoordinator.start()
        
        window.rootViewController = authNavController
        window.makeKeyAndVisible()
    }
    
    private func showOnbordingIfNeeded() {
        guard onboardingManager.needsOnboarding else {
            return
        }
        let welcomeViewModel = WelcomeViewModel()
        let welcomeViewController = WelcomeViewController(viewModel: welcomeViewModel)
        
        
        welcomeViewModel.onLinkSelected = { url in
            let safariViewController = SFSafariViewController(url: url)
            welcomeViewController.present(safariViewController, animated: true)
        }
        welcomeViewModel.onContinueTapped = {
            self.onboardingManager.markOnboardingCompleted()
            welcomeViewController.dismiss(animated: true)
        }
        
        welcomeViewController.modalPresentationStyle = .fullScreen
        window.rootViewController?.present(welcomeViewController, animated: true)
    }
}
