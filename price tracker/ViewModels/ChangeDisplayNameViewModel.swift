//
//  ChangeDisplayNameViewModel.swift
//  price tracker
//
//  Created by Kris Skierniewski on 17/09/2025.
//

class ChangeDisplayNameViewModel: KTableViewModel {
    
    var rightBarButtonItem: UIBarButtonItem? {
        UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
    }
    
    private let authService: AuthService
    private let combinedRepository: CombinedRepositoryProtocol
    
    private var userObserverHandle: ObserverHandle?
    
    private var user: User?
    private var newDisplayName: String = ""
    
    var navigationTitle: String = "Display name"
    
    var sections: [KTableViewSection] = []
    
    var onSectionsUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onCompleted: (() -> Void)?
    
    
    init(authService: AuthService, combinedRepository: CombinedRepositoryProtocol) {
        self.authService = authService
        self.combinedRepository = combinedRepository
    }
    
    deinit {
        userObserverHandle?.remove()
    }
    
    
    func loadSections() {
        if let currentUserId = authService.currentUserId {
            userObserverHandle = combinedRepository.observeUser(withId: currentUserId, onChange: { [weak self] updatedUser in
                if let updatedUser = updatedUser {
                    self?.user = updatedUser
                    self?.newDisplayName = updatedUser.displayName
                } else {
                    self?.user = User(id: currentUserId, displayName: "")
                }
                self?.updateSections()
            })
        }
    }
    
    private func updateSections() {
        let displayNameRow = KTableViewRow(placeholder: "Display name", text: user?.displayName) { [weak self] newName in
            self?.newDisplayName = newName
        }
        sections = [KTableViewSection(title: "Display name", body: "Choose the name that will appear to members of your group", rows: [displayNameRow])]
        onSectionsUpdated?()
    }
    
    @objc private func saveTapped() {
        guard !newDisplayName.isEmpty else {
            onError?(AuthenticationError.displayNameEmpty)
            return
        }
        
        guard let user = user else {
            onError?(AuthenticationError.notSignedIn)
            return
        }
        
        if newDisplayName == user.displayName {
            onCompleted?()
            return
        }
        
        let updatedUser = User(id: user.id, displayName: newDisplayName)
        combinedRepository.updateUser(updatedUser) { [weak self] result in
            switch result {
            case .success(()):
                self?.onCompleted?()
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    
}
