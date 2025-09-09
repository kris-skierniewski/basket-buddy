//
//  AccountViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

class AccountViewModel {
    
    private let authService: AuthService
    private let combinedRepository: CombinedRepositoryProtocol
    
    var emailAddress: String = ""
    var currency: Currency = .gbp
    
    var onError: ((Error) -> Void)?
    var onCurrencyChanged: ((Currency) -> Void)?
    var onEmailAddressChanged: ((String) -> Void)?
    
    private var userPreferences: UserPreferences?
    private var observerHandle: ObserverHandle?
    private var authStateHandle: AuthStateHandle?
    
    init(authService: AuthService, combinedRepository: CombinedRepositoryProtocol) {
        self.authService = authService
        self.combinedRepository = combinedRepository
    }
    
    func loadUser() {
        
        authStateHandle = authService.addStateDidChangeListener(onChange: { [weak self] in
            self?.emailAddress = self?.authService.currentUserEmailAddress ?? ""
            self?.onEmailAddressChanged?(self?.emailAddress ?? "")
        })
        
        observerHandle = combinedRepository.observePreferences { [weak self] userPreferences in
            if let userPreferences = userPreferences {
                self?.userPreferences = userPreferences
                self?.currency = userPreferences.currency
                self?.onCurrencyChanged?(userPreferences.currency)
            }
        }
    }
    
    func signOut() {
        let result = authService.signOut()
        if case .failure(let error) = result {
            onError?(error)
        }
    }
    
    func deleteAccount() {
        
        combinedRepository.deleteAllUserData { [weak self] result in
            switch result {
            case .success(()):
                
                self?.authService.deleteUser { result in
                    switch result {
                    case .success(()):
                        break
                        //will observer handle this ?
                    case .failure(let error):
                        self?.onError?(error)
                    }
                }
                
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func setCurrencyPreference(_ currency: Currency) {
        var currentUserPreferences = userPreferences ?? UserPreferences()
        currentUserPreferences.currency = currency
        combinedRepository.updateUserPreferences(currentUserPreferences) { [weak self] result in
            switch result {
            case .success(()):
                break
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
}
