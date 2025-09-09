//
//  CreateAccountViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

class CreateAccountViewModel {
    
    private let authService: AuthService
    
    var onSuccess: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    var emailAddress: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func createAccount() {
        guard validateInput() else {
            return
        }
        
        authService.createUser(email: emailAddress, password: password) { [weak self] result in
            switch result {
            case .success(()):
                self?.onSuccess?()
                
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func validateInput() -> Bool {
        guard !emailAddress.isEmpty else {
            onError?(AuthenticationError.emptyEmailAddress)
            return false
        }
        
        guard !password.isEmpty else {
            onError?(AuthenticationError.emptyPassword)
            return false
        }
        
        guard password == confirmPassword else {
            onError?(AuthenticationError.passwordsDontMatch)
            return false
        }
        
        return true
    }
    
    
}
