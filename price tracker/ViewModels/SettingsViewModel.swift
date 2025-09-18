//
//  SettingsViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/09/2025.
//

class SettingsSection {
    var rows: [SettingsRow]
    init(rows: [SettingsRow]) {
        self.rows = rows
    }
}

class SettingsRow {
    let title: String
    let subtitle: String
    var didSelectBlock: (() -> Void)?
    var isHeader: Bool
    
    init(title: String, subtitle: String, isHeader: Bool = false, didSelectBlock: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.isHeader = isHeader
        self.didSelectBlock = didSelectBlock
    }
}


class SettingsViewModel {
    
    private let authService: AuthService
    private let combinedRepository: CombinedRepositoryProtocol
    private let datasetRepository: DatasetRepository
    private let datasetId: String
    private var dataset: Dataset?
    
    private var datasetObserverHandle: ObserverHandle?
    private var userObserverHandle: ObserverHandle?
    private var preferencesObserverHandle: ObserverHandle?
    private var authStateHandle: AuthStateHandle?
    
    private var user: User?
    private var emailAddress: String = ""
    private var userPreferences: UserPreferences?
    
    var sections: [SettingsSection] = []
    var onSectionsUpdated: (() -> Void)?
    
    var onError: ((Error) -> Void)?
    
    var onDisplayNameTapped: (() -> Void)?
    var onCurrencyTapped: (() -> Void)?
    var onInviteTapped: (() -> Void)?
    var onJoinGroupTapped: (() -> Void)?
    var onDeleteAccountTapped: (() -> Void)?
    var onAcknowledgementsTapped: (() -> Void)?
    
    init(authService: AuthService, combinedRepository: CombinedRepositoryProtocol, datasetRepository: DatasetRepository, datasetId: String) {
        self.authService = authService
        self.combinedRepository = combinedRepository
        self.datasetRepository = datasetRepository
        self.datasetId = datasetId
    }
    
    deinit {
        preferencesObserverHandle?.remove()
        authStateHandle?.remove()
        userObserverHandle?.remove()
        datasetObserverHandle?.remove()
    }
    
    func loadUser() {
        authStateHandle = authService.addStateDidChangeListener(onChange: { [weak self] in
            self?.emailAddress = self?.authService.currentUserEmailAddress ?? ""
            self?.updateSections()
        })
        
        preferencesObserverHandle = combinedRepository.observePreferences { [weak self] userPreferences in
            if let userPreferences = userPreferences {
                self?.userPreferences = userPreferences
                self?.updateSections()
            } else {
                self?.userPreferences = UserPreferences()
                self?.updateSections()
            }
        }
        
        if let currentUserId = authService.currentUserId {
            userObserverHandle = combinedRepository.observeUser(withId: currentUserId, onChange: { [weak self] updatedUser in
                if let updatedUser = updatedUser {
                    self?.user = updatedUser
                } else {
                    self?.user = User(id: currentUserId, displayName: "")
                }
                self?.updateSections()
            })
        }
        
        datasetObserverHandle = datasetRepository.observeDataset(withId: datasetId, onChange: { [weak self] dataset in
            if let dataset = dataset {
                self?.dataset = dataset
            }
        })
    }
    
    
    private func updateSections() {
        var newSections = [SettingsSection]()
        let firstSection = SettingsSection(rows: [SettingsRow(title: "You are signed in with:", subtitle: emailAddress, isHeader: true)])
        newSections.append(firstSection)
        
        let displayNameRow = SettingsRow(title: "Display name", subtitle: user?.displayName ?? "", didSelectBlock: onDisplayNameTapped)
        
        let currencyRow = SettingsRow(title: "Currency", subtitle: userPreferences?.currency.symbol ?? "", didSelectBlock: onCurrencyTapped)
        
        let inviteRow = SettingsRow(title: "Invite friends to join your group", subtitle: "", didSelectBlock: onInviteTapped)
        
        let joinRow = SettingsRow(title: "Join an existing group", subtitle: "", didSelectBlock: onJoinGroupTapped)
        
        
        let deleteAccountRow = SettingsRow(title: "Delete account", subtitle: "", didSelectBlock: onDeleteAccountTapped)
        
        let secondSection = SettingsSection(rows: [displayNameRow, currencyRow, inviteRow, joinRow, deleteAccountRow])
        newSections.append(secondSection)
        
        let acknowdlegementsRow = SettingsRow(title: "Acknowledgements", subtitle: "", didSelectBlock: onAcknowledgementsTapped)
        let thirdSection = SettingsSection(rows: [acknowdlegementsRow])
        newSections.append(thirdSection)
        
        self.sections = newSections
        onSectionsUpdated?()
        
    }
    
    func signOut() {
        let result = authService.signOut()
        if case .failure(let error) = result {
            onError?(error)
        }
    }
    
    func deleteAccount() {
        guard let dataset = dataset, let user = user else {
            onError?(RepositoryError.cannotFetchDataset)
            return
        }
        let shouldDeleteDataset = dataset.members.count == 1
        if shouldDeleteDataset {
            deleteWholeDataset()
        } else {
            deleteUserFromDataset()
        }
    }
    
    private func deleteUserFromDataset() {
        guard let currentUserId = authService.currentUserId, let datasetId = dataset?.id else {
            return
        }
        combinedRepository.deleteAllUserData(userId: currentUserId) { result in
            switch result {
            case .success():
                self.datasetRepository.deleteUserFromDataset(datasetId: datasetId, userId: currentUserId) { result in
                    switch result {
                    case .success():
                        self.deleteUserData()
                    case .failure(let error):
                        self.onError?(error)
                    }
                }
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    private func deleteWholeDataset() {
        //app coordinator pause observers?
        datasetRepository.deleteDataset(withId: datasetId) { result in
            switch result {
            case .success():
                self.deleteUserData()
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    private func deleteUserData() {
        guard let user = user else {
            onError?(RepositoryError.cannotFetchDataset)
            return
        }
        combinedRepository.deleteUser(user) { result in
            switch result {
            case .success():
                self.deleteUser()
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    private func deleteUser() {
        authService.deleteUser { result in
            switch result {
            case .success():
                break
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
}
