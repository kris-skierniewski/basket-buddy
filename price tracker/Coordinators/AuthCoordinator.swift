//
//  AuthCoordinator.swift
//  price tracker
//
//  Created by Kris Skierniewski on 03/09/2025.
//

class AuthCoordinator {
    private let navigationController: UINavigationController
    private let authService: AuthService
    private let userRepository: UserRepository
    
    private var signInViewModel: SignInViewModel?
    private var createAccountViewModel: CreateAccountViewModel?
    
    init(navigationController: UINavigationController, authService: AuthService, userRepository: UserRepository) {
        self.navigationController = navigationController
        self.authService = authService
        self.userRepository = userRepository
    }
    
    func start() {
        
        signInViewModel = SignInViewModel(authService: authService)
        
        signInViewModel?.onError = { [weak self] error in
            self?.showErrorAlert(error: error)
        }
        
        signInViewModel?.onCreateAccountTapped = showCreateAccountViewController(inviteCode:)
        
        let signInViewController = SignInViewController(viewModel: signInViewModel!)
        
        navigationController.viewControllers = [signInViewController]
    }
    
    func showInvite(inviteCode: String) {
        signInViewModel?.showInvite(inviteCode: inviteCode)
        createAccountViewModel?.showInvite(inviteCode: inviteCode)
    }
    
    private func showCreateAccountViewController(inviteCode: String?) {
        createAccountViewModel = CreateAccountViewModel(authService: authService, userRepository: userRepository)
        createAccountViewModel?.inviteCode = inviteCode
        createAccountViewModel?.onError = { [weak self] error in
            self?.showErrorAlert(error: error)
        }
        let viewController = CreateAccountViewController(viewModel: createAccountViewModel!)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Sorry, something went wrong...", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        navigationController.topViewController?.present(alert, animated: true)
    }
}
