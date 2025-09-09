//
//  AppCoordinator.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

import FirebaseAuth
import SafariServices

class AppCoordinator {
    let window: UIWindow
    
    var authStateHandle: AuthStateHandle?
    var authService: AuthService
    
    let onboardingManager = OnboardingManager.shared
    
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
                self.showMainFlow()
            } else {
                self.showAuthFlow()
            }
            self.showOnbordingIfNeeded()
        }
    }
    
    private func showMainFlow() {
        
        let firebaseDatabaseService = FirebaseDatabaseService()
        let productRepository = FirebaseProductRepository(firebaseService: firebaseDatabaseService, userId: currentUserId!)
        let shopRepository = FirebaseShopRepository(firebaseService: firebaseDatabaseService, userId: currentUserId!)
        let priceRepository = FirebasePriceRepository(firebaseService: firebaseDatabaseService, userId: currentUserId!)
        let userPreferencesRepository = FirebaseUserPreferenceRepository(firebaseService: firebaseDatabaseService, userId: currentUserId!)
        let shoppingListRepository = FirebaseShoppingListRepository(firebaseService: firebaseDatabaseService, userId: currentUserId!)
        let combinedRepository = CombinedRepository(productRepository: productRepository, shopRepository: shopRepository, priceRepository: priceRepository, userPreferencesRepository: userPreferencesRepository, shoppingListRepository: shoppingListRepository)
        
        let tabBarController = UITabBarController()
        
        let productTableNav = UINavigationController()
        let productCoordinator = ProductCoordinator(navigationController: productTableNav, combinedRepository: combinedRepository)
        productCoordinator.start()
        
        let shoppingListNav = UINavigationController()
        let shoppingListCoordinator = ShoppingListCoordinator(navigationController: shoppingListNav, combinedRepository: combinedRepository)
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
