//
//  DatasetInformationViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 16/09/2025.
//

import UIKit

struct DatasetMemberRow: Comparable {
    var displayName: String
    var isCurrentUser: Bool
    
    static func < (lhs: DatasetMemberRow, rhs: DatasetMemberRow) -> Bool {
        return lhs.displayName < rhs.displayName
    }
}

class DatasetInformationViewModel {
    
    private let combinedRepository: CombinedRepositoryProtocol
    private let datasetRepository: DatasetRepository
    private let authService: AuthService
    private let datasetId: String
    private var dataset: Dataset?
    private var users: [User] = []
    
    private var usersObserverHandle: ObserverHandle?
    private var datasetObserverHandle: ObserverHandle?
    
    var rows: [DatasetMemberRow] = []
    var onRowsUpdated: (() -> Void)?
    var onInviteTapped: ((UIView) -> Void)?
    
    init(datasetId: String, combinedRepository: CombinedRepositoryProtocol, datasetRepository: DatasetRepository, authService: AuthService) {
        self.datasetId = datasetId
        self.combinedRepository = combinedRepository
        self.datasetRepository = datasetRepository
        self.authService = authService
    }
    
    func loadDatasetInformation() {
        datasetObserverHandle = datasetRepository.observeDataset(withId: datasetId, onChange: { [weak self] updatedDataset in
            if let updatedDataset = updatedDataset {
                self?.dataset = updatedDataset
                self?.updateRows()
            }
        })
        usersObserverHandle = combinedRepository.observeUsers(onChange: { [weak self] updatedUsers in
            self?.users = updatedUsers
            self?.updateRows()
        })
    }
    
    private func updateRows() {
        
        guard let currentUserId = authService.currentUserId else { return }
        let mappedUsers = dataset?.members.compactMap { userId, isMember in
            if isMember, let matchingUser = users.first(where: { $0.id == userId }) {
                return matchingUser
            }
            return nil
        } ?? [User]()
        
        rows = mappedUsers.map({ user in
            DatasetMemberRow(displayName: user.displayName, isCurrentUser: currentUserId == user.id)
        }).sorted()
        onRowsUpdated?()
    }
    
    func invite(sourceView: UIView) {
        onInviteTapped?(sourceView)
    }
    
}
