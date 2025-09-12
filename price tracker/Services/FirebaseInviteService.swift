//
//  FirebaseInviteService.swift
//  price tracker
//
//  Created by Kris Skierniewski on 11/09/2025.
//

struct Invite: Codable {
    let code: String
    let datasetId: String
    let invitedBy: String
    let createdAt: TimeInterval
    let expiresAt: TimeInterval
}

protocol InviteServiceProtocol {
    func createInvite(completion: @escaping (Result<String, Error>) -> Void)
    func redeemInvite(code: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class FirebaseInviteService: InviteServiceProtocol {
    
    let databaseService: FirebaseDatabaseService
    let datasetRepository: FirebaseDatasetRepository
    let authService: AuthService
    
    init(databaseService: FirebaseDatabaseService, datasetRepository: FirebaseDatasetRepository, authService: AuthService) {
        self.databaseService = databaseService
        self.datasetRepository = datasetRepository
        self.authService = authService
    }
    
    func createInvite(completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            return
        }
        
        let code = generateCode()
        
        datasetRepository.getUserDatasetId { [weak self] result in
            switch result {
            case .success(let datasetId):
                guard let datasetId = datasetId else {
                    completion(.failure(RepositoryError.cannotFetchDataset))
                    return
                }
                
                let now = Date().timeIntervalSince1970
                let expiresAt = now + (60 * 60 * 24 * 7)
                let invite = Invite(code: code,
                                    datasetId: datasetId,
                                    invitedBy: userId,
                                    createdAt: Date().timeIntervalSince1970,
                                    expiresAt: expiresAt)
                
                self?.databaseService.update(invite, at: "invites/\(code)") { result in
                    switch result {
                    case .success(()):
                        completion(.success(code))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func redeemInvite(code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        databaseService.getValue("invites/\(code)", as: Invite.self) { [weak self] result in
            switch result {
            case .success(let invite):
                if let invite = invite {
                    if Date().timeIntervalSince1970 <= invite.expiresAt {
                        self?.joinDatasetAndDeleteInvite(invite, completion: completion)
                    } else {
                        completion(.failure(InviteError.inviteExpired))
                    }
                } else {
                    completion(.failure(InviteError.inviteNotFound))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func joinDatasetAndDeleteInvite(_ invite: Invite, completion: @escaping (Result<Void, Error>) -> Void) {
        datasetRepository.joinDataset(withId: invite.datasetId) { [weak self] result in
            switch result {
            case .success(()):
                self?.databaseService.delete(at: "invites/\(invite.code)", completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    
    private func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).compactMap({ _ in chars.randomElement() }))
    }
    
}

