//
//  MockInviteService.swift
//  price tracker
//
//  Created by Kris Skierniewski on 12/09/2025.
//
@testable import price_tracker
import XCTest

class MockInviteService: InviteServiceProtocol {
    
    var mockUserId: String = ""
    var mockDatasetId: String = ""
    
    var mockInvites: [Invite] = []
    
    func createInvite(completion: @escaping (Result<String, any Error>) -> Void) {
        
        let invite = Invite(code: "ABC123", datasetId: mockDatasetId, invitedBy: mockUserId, createdAt: Date().timeIntervalSince1970, expiresAt: Date().timeIntervalSince1970 + 604800)
        mockInvites.append(invite)
        completion(.success(invite.code))
    }
    
    func redeemInvite(code: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        let matchingInvite = mockInvites.first(where: { $0.code == code })
        if let matchingInvite = matchingInvite,
           Date().timeIntervalSince1970 <= matchingInvite.expiresAt {
            
            mockInvites.removeAll { $0.code == code }
            completion(.success(()))
        }
    }
    
    
    
}
