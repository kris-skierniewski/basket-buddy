//
//  JoingGroupViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/09/2025.
//

class JoinGroupViewModel: KTableViewModel {
    
    private let inviteService: InviteServiceProtocol
    private let datasetRepository: DatasetRepository
    
    private var inviteCode: String = ""
    
    
    var navigationTitle: String = "Join group"
    var rightBarButtonItem: UIBarButtonItem? {
        UIBarButtonItem(title: "Join", style: .done, target: self, action: #selector(joinTapped))
    }
    var sections: [KTableViewSection] = []
    
    var onSectionsUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(inviteService: InviteServiceProtocol, datasetRepository: DatasetRepository) {
        self.inviteService = inviteService
        self.datasetRepository = datasetRepository
    }
    
    func loadSections() {
        let inviteCodeRow = KTableViewRow(placeholder: "Invite code", text: nil) { [weak self] code in
            self?.inviteCode = code
        }
        sections = [
            KTableViewSection(title: "Enter your invite code", body: "Joining a new group means that you will leave your current group. You will also lose all existing products, prices and shops.", rows: [inviteCodeRow])
        ]
        onSectionsUpdated?()
    }
    
    @objc private func joinTapped() {
        guard !inviteCode.isEmpty else {
            onError?(InviteError.inviteCodeEmpty)
            return
        }
        
        inviteService.redeemInvite(code: inviteCode) { [weak self] result in
            switch result {
            case .success(()):
                print("JOIN SUCCESSFUL")
                //self?.onSuccess?()
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
}
