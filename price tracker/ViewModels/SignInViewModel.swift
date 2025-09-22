//
//  SignInViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

class SignInViewModel {
    
    private let authService: AuthService
    private var inviteCode: String?
    
    var emailAddress: String = ""
    var password: String = ""
    
    var inviteNoticeString = ""
    
    var onSignInSuccess: (() -> Void)?
    var onResetPasswordSuccess: (() -> Void)?
    var onCreateAccountTapped: ((String?) -> Void)?
    var onError: ((Error)-> Void)?
    var onInviteNoticeStringChanged: (() -> Void)?
    
    var onLoading: ((Bool) -> Void)?
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func showInvite(inviteCode: String) {
        self.inviteCode = inviteCode
        inviteNoticeString = "You have been invited to join a team\nBut first, sign in or create an account."
        onInviteNoticeStringChanged?()
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
        onCreateAccountTapped?(inviteCode)
    }
    
}
