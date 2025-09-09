//
//  SignInViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

class SignInViewModel {
    
    private let authService: AuthService
    
    var emailAddress: String = ""
    var password: String = ""
    
    var onSignInSuccess: (() -> Void)?
    var onResetPasswordSuccess: (() -> Void)?
    var onCreateAccountTapped: (() -> Void)?
    var onError: ((Error)-> Void)?
    
    var onLoading: ((Bool) -> Void)?
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func signIn() {
        onLoading?(true)
        authService.signIn(email: emailAddress, password: password) { [weak self] result in
            self?.onLoading?(false)
            switch result {
            case .success(()):
                self?.onSignInSuccess?()
                
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func sendPasswordReset() {
        onLoading?(true)
        authService.sendPasswordReset(with: emailAddress) { [weak self] result in
            self?.onLoading?(false)
            switch result {
            case .success(()):
                self?.onResetPasswordSuccess?()
                
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func createAccount() {
        onCreateAccountTapped?()
    }
    
}
