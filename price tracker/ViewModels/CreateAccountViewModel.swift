//
//  CreateAccountViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

class CreateAccountViewModel {
    
    private let authService: AuthService
    private let userRepository: UserRepository
    
    var onSuccess: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    var displayName: String = ""
    var emailAddress: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    
    init(authService: AuthService, userRepository: UserRepository) {
        self.authService = authService
        self.userRepository = userRepository
    }
    
    func createAccount() {
        guard validateInput() else {
            return
        }
        
        authService.createUser(email: emailAddress, password: password) { result in
            switch result {
            case .success(let userId):
                
                let user = User(id: userId, displayName: self.displayName)
                self.userRepository.updateUser(user) { result in
                    switch result {
                    case .success():
                        self.onSuccess?()
                    case .failure(let error):
                        self.onError?(error)
                    }
                }
                
                
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    func validateInput() -> Bool {
        guard !emailAddress.isEmpty else {
            onError?(AuthenticationError.emptyEmailAddress)
            return false
        }
        
        guard !displayName.isEmpty else {
            onError?(AuthenticationError.displayNameEmpty)
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
