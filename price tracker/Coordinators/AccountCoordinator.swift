//
//  AccountCoordinator.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

class AccountCoordinator {
    private let navigationController: UINavigationController
    private let combinedRepository: CombinedRepositoryProtocol
    private let authService: AuthService
    
    init(navigationController: UINavigationController, combinedRepository: CombinedRepositoryProtocol, authService: AuthService) {
        self.navigationController = navigationController
        self.combinedRepository = combinedRepository
        self.authService = authService
    }
    
    func start() {
        let accountViewModel = AccountViewModel(authService: authService, combinedRepository: combinedRepository)
        accountViewModel.onError = { error in
            self.showErrorAlert(error: error)
        }
        let accountViewController = AccountViewController(viewModel: accountViewModel)
        navigationController.pushViewController(accountViewController, animated: false)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Sorry, something went wrong...", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        navigationController.topViewController?.present(alert, animated: true)
    }
    
}
