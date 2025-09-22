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
    private var tabBarController: UITabBarController?
    
    private var authStateHandle: AuthStateHandle?
    private var authService: AuthService
    private var firebaseDatabaseService: FirebaseDatabaseService
    
    private let onboardingManager = OnboardingManager.shared
    
    private var inviteService: FirebaseInviteService?
    private var datasetRepository: FirebaseDatasetRepository?
    private var userDatasetIdHandle: ObserverHandle?
    private var datasetHandle: ObserverHandle?
    
    private var handleInviteBlock: ((String) -> Void)?
    private var isReadyForInvite: Bool = false
    private var inviteCode: String?
    
    var currentUserId: String? {
        return authService.currentUserId
    }
    
    init(window: UIWindow) {
        self.window = window
        self.authService = FirebaseAuthService()
        self.firebaseDatabaseService = FirebaseDatabaseService()
    }
    
    func start() {
        
        authStateHandle = authService.addStateDidChangeListener {
            if self.currentUserId != nil {
                self.showDatasetLoadingFlow()
            } else {
                self.showAuthFlow()
            }
        }
    }
    
    private var userDatasetId: String?
    private var dataset: Dataset?
    
    private func showDatasetLoadingFlow() {
        
        datasetRepository = FirebaseDatasetRepository(firebaseService: firebaseDatabaseService, userId: currentUserId!)
        inviteService = FirebaseInviteService(databaseService: firebaseDatabaseService, datasetRepository: datasetRepository!, authService: authService)
        
        let loadingViewController = LoadingViewController()
        window.rootViewController = loadingViewController
        window.makeKeyAndVisible()
        
        getUserDatasetId()
    }
    
    private var getUserIdFailCount: Int = 0
    private func getUserDatasetId() {
        datasetRepository?.getUserDatasetId { [weak self] result in
            switch result {
            case .success(let datasetId):
                if let datasetId = datasetId {
                    self?.userDatasetId = datasetId
                    self?.observeUserDatasetId()
                    self?.getDataset(withId: datasetId)
                } else {
                    self?.showSelectDatasetFlow()
                }
            case .failure(let error):
                self?.getUserIdFailCount += 1
                if (self?.getUserIdFailCount ?? 0) <= 5 {
                    self?.showErrorAlert(error: error, withRetryBlock: self?.getUserDatasetId)
                } else { //give up
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func showSelectDatasetFlow() {
        guard let datasetRepository = datasetRepository, let inviteService = inviteService else {
            return
        }
        let viewModel = SelectDatasetViewModel(authService: authService, datasetRepository: datasetRepository, inviteService: inviteService)
        viewModel.onSuccess = { [weak self] in
            self?.showDatasetLoadingFlow()
        }
        viewModel.onError = showErrorAlert(error:)
        let viewController = SelectDatasetViewController(viewModel: viewModel)
        
        window.rootViewController = viewController
        showOnbordingIfNeeded { [weak self] in
            self?.isReadyForInvite = true
            if let inviteCode = self?.inviteCode {
                viewModel.showInvite(inviteCode: inviteCode)
            } else {
                self?.handleInviteBlock = viewModel.showInvite(inviteCode:)
            }
        }
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
    
    private var getDatasetFailCount: Int = 0
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
                    //user datset id set but dataset is missing! set it up
                    // can happen if onboarding is left unfinished
                    self?.setupNewDataset(withId: datasetId, userId: currentUserId)
                }
            case .failure(let error):
                self?.getDatasetFailCount += 1
                if (self?.getDatasetFailCount ?? 0) <= 5 {
                    self?.showErrorAlert(error: error, withRetryBlock: {
                        self?.getDataset(withId: datasetId)
                    })
                } else {
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private var setupNewDatasetFailCount: Int = 0
    private func setupNewDataset(withId datasetId: String, userId: String) {
        let newDataset = Dataset(id: datasetId, members: [userId: true])
        datasetRepository?.updateDataset(newDataset) { [weak self] result in
            switch result {
            case .success():
                self?.observeDataSet(withId: datasetId)
            case .failure(let error):
                self?.setupNewDatasetFailCount += 1
                if (self?.setupNewDatasetFailCount ?? 0) <= 5 {
                    self?.showErrorAlert(error: error, withRetryBlock: {
                        self?.setupNewDataset(withId: datasetId, userId: userId)
                    })
                } else {
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func observeDataSet(withId datasetId: String) {
        datasetHandle?.remove()
        datasetHandle = datasetRepository?.observeDataset(withId: datasetId, onChange: { [weak self] updatedDataset in
            if let updatedDataset = updatedDataset,
               updatedDataset != self?.dataset {
                
                let isUserStillInDataset = updatedDataset.members.contains(where: { $0.key == self?.authService.currentUserId && $0.value == true })
                
                if isUserStillInDataset {
                    self?.dataset = updatedDataset
                    self?.showMainFlow(forDataset: updatedDataset)
                } else {
                    self?.dataset = nil
                    self?.showDatasetLoadingFlow()
                }
            }
        })
        
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Sorry, something went wrong...", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        window.rootViewController?.present(alert, animated: true)
    }
    
    private func showErrorAlert(error: Error, withRetryBlock retryBlock: (() -> Void)?) {
        let alert = UIAlertController(title: "Sorry, something went wrong...", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { _ in
            retryBlock?()
        }))
        
        window.rootViewController?.present(alert, animated: true)
    }
    
    private func showMainFlow(forDataset dataset: Dataset) {
        
        let productRepository = FirebaseProductRepository(firebaseService: firebaseDatabaseService, datasetId: dataset.id)
        let shopRepository = FirebaseShopRepository(firebaseService: firebaseDatabaseService, datasetId: dataset.id)
        let priceRepository = FirebasePriceRepository(firebaseService: firebaseDatabaseService, datasetId: dataset.id)
        let userPreferencesRepository = FirebaseUserPreferenceRepository(firebaseService: firebaseDatabaseService, datasetId: dataset.id)
        let shoppingListRepository = FirebaseShoppingListRepository(firebaseService: firebaseDatabaseService, datasetId: dataset.id)
        let userRepository = FirebaseUserRepository(firebaseService: firebaseDatabaseService)
        let combinedRepository = CombinedRepository(productRepository: productRepository, shopRepository: shopRepository, priceRepository: priceRepository, userPreferencesRepository: userPreferencesRepository, shoppingListRepository: shoppingListRepository, userRepository: userRepository)
        
        tabBarController = UITabBarController()
        
        let productTableNav = UINavigationController()
        let productCoordinator = ProductCoordinator(navigationController: productTableNav,
                                                    datasetId: dataset.id,
                                                    datasetRepository: datasetRepository!,
                                                    combinedRepository: combinedRepository,
                                                    inviteService: inviteService!,
                                                    authService: authService)
        productCoordinator.start()
        
        let shoppingListNav = UINavigationController()
        let shoppingListCoordinator = ShoppingListCoordinator(navigationController: shoppingListNav,
                                                              combinedRepository: combinedRepository,
                                                              inviteService: inviteService!,
                                                              authService: authService,
                                                              datasetRepository: datasetRepository!,
                                                              datasetId: dataset.id)
        shoppingListCoordinator.start()
        
        let accountNav = UINavigationController()
        let accountCoordinator = AccountCoordinator(navigationController: accountNav,
                                                    combinedRepository: combinedRepository,
                                                    authService: authService,
                                                    inviteService: inviteService!,
                                                    datasetRepository: datasetRepository!,
                                                    datasetId: dataset.id)
        accountCoordinator.start()
        
        productTableNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        shoppingListNav.tabBarItem = UITabBarItem(title: "Shopping List", image: UIImage(systemName: "cart"), tag: 1)
        accountNav.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.crop.circle"), tag: 2)
        tabBarController?.viewControllers = [productTableNav, shoppingListNav, accountNav]
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        
        showOnbordingIfNeeded { [weak self] in
            self?.isReadyForInvite = true
            if let inviteCode = self?.inviteCode {
                self?.showJoingGroupViewController(inviteCode: inviteCode)
            } else {
                self?.handleInviteBlock = self?.showJoingGroupViewController(inviteCode:)
            }
        }
    }
    
    private func showJoingGroupViewController(inviteCode: String) {
        let viewModel = JoinGroupViewModel(inviteService: inviteService!, datasetRepository: datasetRepository!, inviteCode: inviteCode)
        
        viewModel.onError = showErrorAlert(error:)
        let viewController = KTableViewController(viewModel: viewModel)
        (tabBarController?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: true)
    }
    
    private func showAuthFlow() {
        let authNavController = UINavigationController()
        let userRepository = FirebaseUserRepository(firebaseService: firebaseDatabaseService)
        let authCoordinator = AuthCoordinator(navigationController: authNavController, authService: authService, userRepository: userRepository)
        authCoordinator.start()
        
        window.rootViewController = authNavController
        window.makeKeyAndVisible()
        showOnbordingIfNeeded { [weak self] in
            self?.isReadyForInvite = true
            if let inviteCode = self?.inviteCode {
                authCoordinator.showInvite(inviteCode: inviteCode)
            } else {
                self?.handleInviteBlock = authCoordinator.showInvite(inviteCode:)
            }
        }
    }
    
    private func showOnbordingIfNeeded(completion: @escaping () -> Void) {
        guard onboardingManager.needsOnboarding else {
            completion()
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
            welcomeViewController.dismiss(animated: true, completion: completion)
        }
        
        welcomeViewController.modalPresentationStyle = .fullScreen
        window.rootViewController?.present(welcomeViewController, animated: true)
    }
    
    func handleInviteDeepLink(inviteCode: String) {
        if isReadyForInvite {
            handleInviteBlock?(inviteCode)
        } else {
            self.inviteCode = inviteCode
        }
    }
}
