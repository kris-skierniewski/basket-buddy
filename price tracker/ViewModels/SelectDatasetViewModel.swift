//
//  SelectDatasetViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 11/09/2025.
//

class SelectDatasetViewModel {
    
    private let authService: AuthService
    private let datasetRepository: DatasetRepository
    private let inviteService: InviteServiceProtocol
    
    var inviteCode: String = ""
    
    var onInviteCodeUpdated: (() -> Void)?
    var onSuccess: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(authService: AuthService, datasetRepository: DatasetRepository, inviteService: InviteServiceProtocol) {
        self.authService = authService
        self.datasetRepository = datasetRepository
        self.inviteService = inviteService
    }
    
    func showInvite(inviteCode: String) {
        self.inviteCode = inviteCode
        onInviteCodeUpdated?()
    }
    
    func joinWithCode() {
        guard !inviteCode.isEmpty else {
            onError?(InviteError.inviteCodeEmpty)
            return
        }
        
        inviteService.redeemInvite(code: inviteCode) { [weak self] result in
            switch result {
            case .success(()):
                self?.onSuccess?()
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func joinWithoutCode() {
        datasetRepository.setupUserDataset { [weak self] result in
            switch result {
            case .success((_)):
                self?.onSuccess?()
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func signOut() {
        let result = authService.signOut()
        switch result {
        case .success():
            break
        case .failure(let error):
            onError?(error)
        }
    }
}
