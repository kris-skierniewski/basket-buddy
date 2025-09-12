//
//  SelectDatasetViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 11/09/2025.
//

class SelectDatasetViewModel {
    
    private let datasetRepository: DatasetRepository
    private let inviteService: InviteServiceProtocol
    
    var inviteCode: String = ""
    
    var onSuccess: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(datasetRepository: DatasetRepository, inviteService: InviteServiceProtocol) {
        self.datasetRepository = datasetRepository
        self.inviteService = inviteService
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
}
