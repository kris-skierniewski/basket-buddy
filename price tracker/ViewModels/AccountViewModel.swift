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
    
    private var user: User?
    var displayName: String {
        return user?.displayName ?? ""
    }
    var newDisplayName: String = ""
    
    var isEditing: Bool = false {
        didSet {
            onIsEditingChanged?(isEditing)
        }
    }
    
    var onIsEditingChanged: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?
    var onCurrencyChanged: ((Currency) -> Void)?
    var onEmailAddressChanged: ((String) -> Void)?
    var onDisplayNameChanged: ((String) -> Void)?
    
    private var userObserverHandle: ObserverHandle?
    private var userPreferences: UserPreferences?
    private var preferencesObserverHandle: ObserverHandle?
    private var authStateHandle: AuthStateHandle?
    
    init(authService: AuthService, combinedRepository: CombinedRepositoryProtocol) {
        self.authService = authService
        self.combinedRepository = combinedRepository
    }
    
    deinit {
        preferencesObserverHandle?.remove()
        authStateHandle?.remove()
        userObserverHandle?.remove()
    }
    
    func loadUser() {
        
        authStateHandle = authService.addStateDidChangeListener(onChange: { [weak self] in
            self?.emailAddress = self?.authService.currentUserEmailAddress ?? ""
            self?.onEmailAddressChanged?(self?.emailAddress ?? "")
        })
        
        preferencesObserverHandle = combinedRepository.observePreferences { [weak self] userPreferences in
            if let userPreferences = userPreferences {
                self?.userPreferences = userPreferences
                self?.currency = userPreferences.currency
                self?.onCurrencyChanged?(userPreferences.currency)
            }
        }
        
        if let currentUserId = authService.currentUserId {
            userObserverHandle = combinedRepository.observeUser(withId: currentUserId, onChange: { [weak self] updatedUser in
                if let updatedUser = updatedUser {
                    self?.user = updatedUser
                    self?.onDisplayNameChanged?(updatedUser.displayName)
                } else {
                    self?.user = User(id: currentUserId, displayName: "")
                }
            })
        }
    }
    
    func signOut() {
        let result = authService.signOut()
        if case .failure(let error) = result {
            onError?(error)
        }
    }
    
    func deleteAccount() {
        
//        combinedRepository.deleteAllUserData { [weak self] result in
//            switch result {
//            case .success(()):
//                
//                self?.authService.deleteUser { result in
//                    switch result {
//                    case .success(()):
//                        break
//                        //will observer handle this ?
//                    case .failure(let error):
//                        self?.onError?(error)
//                    }
//                }
//                
//            case .failure(let error):
//                self?.onError?(error)
//            }
//        }
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
    
    func saveUser() {
        guard !newDisplayName.isEmpty else {
            onError?(AuthenticationError.displayNameEmpty)
            return
        }
        
        guard let user = user else {
            onError?(AuthenticationError.notSignedIn)
            return
        }
        
        if newDisplayName == user.displayName {
            isEditing = false
            return
        }
        
        let updatedUser = User(id: user.id, displayName: newDisplayName)
        combinedRepository.updateUser(updatedUser) { [weak self] result in
            switch result {
            case .success(()):
                print("success")
                self?.isEditing = false
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
}
