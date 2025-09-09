//
//  MockAuthService.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

@testable import price_tracker

class MockAuthStateHandle: AuthStateHandle {
    var hasBeenRemoved: Bool = false
    
    func remove() {
        hasBeenRemoved = true
    }
    
}

class MockAuthService: AuthService {
    
    var currentUserId: String? {
        return mockUserId
    }
    
    var currentUserEmailAddress: String? {
        return mockUserEmailAddress
    }
    
    var mockUserId: String?
    var mockUserEmailAddress: String?
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        completion(.success(()))
    }
    
    func createUser(email: String, password: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        completion(.success(()))
    }
    
    func sendPasswordReset(with email: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        completion(.success(()))
    }
    
    var numberOfTimesSignOutCalled = 0
    func signOut() -> Result<Void, any Error> {
        numberOfTimesSignOutCalled += 1
        return .success(())
    }
    
    var numberOfTimesDeleteUserCalled = 0
    func deleteUser(_ completion: @escaping (Result<Void, any Error>) -> Void) {
        numberOfTimesDeleteUserCalled += 1
        completion(.success(()))
    }
    
    func addStateDidChangeListener(onChange: @escaping () -> Void) -> any AuthStateHandle {
        onChange()
        return MockAuthStateHandle()
    }
}
