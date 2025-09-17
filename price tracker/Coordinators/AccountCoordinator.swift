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
    private let inviteService: InviteServiceProtocol
    private let datasetRepository: DatasetRepository
    private let datasetId: String
    
    init(navigationController: UINavigationController, combinedRepository: CombinedRepositoryProtocol, authService: AuthService, inviteService: InviteServiceProtocol, datasetRepository: DatasetRepository, datasetId: String) {
        self.navigationController = navigationController
        self.combinedRepository = combinedRepository
        self.authService = authService
        self.inviteService = inviteService
        self.datasetRepository = datasetRepository
        self.datasetId = datasetId
    }
    
    func start() {
        
        let settingsViewModel = SettingsViewModel(authService: authService, combinedRepository: combinedRepository, datasetRepository: datasetRepository, datasetId: datasetId)
        
        settingsViewModel.onError = showErrorAlert(error:)
        settingsViewModel.onDisplayNameTapped = showChangeDisplayNameViewController
        settingsViewModel.onCurrencyTapped = showCurrencySelectionViewController
        settingsViewModel.onInviteTapped = showDatasetInformationViewController
        settingsViewModel.onJoinGroupTapped = showJoinGroupViewController
        settingsViewModel.onDeleteAccountTapped = {
            self.showDeleteAccountAlert(viewModel: settingsViewModel)
        }
        
        let settingsViewController = SettingsViewController(viewModel: settingsViewModel)
        navigationController.pushViewController(settingsViewController, animated: false)
    }
    
    private func showChangeDisplayNameViewController() {
        let viewModel = ChangeDisplayNameViewModel(authService: authService, combinedRepository: combinedRepository)
        
        viewModel.onError = showErrorAlert(error:)
        viewModel.onCompleted = {
            self.navigationController.popViewController(animated: true)
        }
        
        let viewController = KTableViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showCurrencySelectionViewController() {
        
        let viewModel = CurrencyTableViewModel(combinedRepository: combinedRepository)
        viewModel.onError = showErrorAlert(error:)
        
        let viewController = KTableViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showDatasetInformationViewController() {
        let viewModel = DatasetInformationViewModel(datasetId: datasetId, combinedRepository: combinedRepository, datasetRepository: datasetRepository, authService: authService)
        viewModel.onInviteTapped = showShareFlow(sourceView:)
        
        let viewController = DatasetInformationViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showShareFlow(sourceView: UIView) {
        
        inviteService.createInvite() { [weak self] result in
            switch result {
            case .success(let invite):
                
                let inviteText = "Lets save money together! Download Basket Buddy and join my group using invite code: \(invite)"
                
                let activityViewController = UIActivityViewController(
                    activityItems: [inviteText],
                    applicationActivities: nil
                )
                
//                 For iPad - required to prevent crash
                if let popover = activityViewController.popoverPresentationController {
                    popover.sourceView = sourceView
                    popover.sourceRect = sourceView.bounds
                    popover.permittedArrowDirections = [.any]
                }
                self?.navigationController.topViewController?.present(activityViewController, animated: true)
                
                
            case .failure(let error):
                self?.showErrorAlert(error: error)
            }
        }
    }
    
    private func showJoinGroupViewController() {
        let viewModel = JoinGroupViewModel(inviteService: inviteService, datasetRepository: datasetRepository)
        
        viewModel.onError = showErrorAlert(error:)
        
        let viewController = KTableViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showDeleteAccountAlert(viewModel: SettingsViewModel) {
        let alertController = UIAlertController(title: "Sorry to see you go", message: "Are you sure you would like to permanently delete your account? All your data will be deleted.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            viewModel.deleteAccount()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        navigationController.topViewController?.present(alertController, animated: true)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Sorry, something went wrong...", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        navigationController.topViewController?.present(alert, animated: true)
    }
    
}
