//
//  MockUserRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 12/09/2025.
//

//TODO: finish

@testable import price_tracker

class MockUserRepository: UserRepository {
    
    var mockUsers: [User] = []
    
    private var usersChangedCallbacks: [(([User]) -> Void)] = []
    private var userChangedCallbacks: [String: [(User?) -> Void]] = [:]
    
    func updateUser(_ user: User, completion: @escaping (Result<Void, any Error>) -> Void) {
        if let index = mockUsers.firstIndex(where: { $0.id == user.id}) {
            mockUsers[index] = user
            
        }
        completion(.success(()))
    }
    
    func observeUser(withId userId: String, onChange: @escaping (User?) -> Void) -> any ObserverHandle {
         var callbacks = userChangedCallbacks[userId] ?? []
        callbacks.append(onChange)
        userChangedCallbacks[userId] = callbacks
        
        
        return MockObserverHandle()
    }
    
    func deleteUser(_ user: User, completion: @escaping (Result<Void, any Error>) -> Void) {
        if let index = mockUsers.firstIndex(where: { $0.id == user.id}) {
            mockUsers.remove(at: index)
            
        }
        triggerObserversForUsers()
        triggerObserversForUser(withId: user.id)
        completion(.success(()))
    }
    
    func observeUsers(onChange: @escaping ([User]) -> Void) -> any ObserverHandle {
        usersChangedCallbacks.append(onChange)
        onChange(mockUsers)
        return MockObserverHandle()
    }
    
    private func triggerObserversForUsers() {
        usersChangedCallbacks.forEach({ $0(mockUsers) })
    }
    
    private func triggerObserversForUser(withId userId: String) {
        let callBacks = userChangedCallbacks[userId] ?? []
        let user = mockUsers.first(where: { $0.id == userId })
        
        callBacks.forEach({
            $0(user)
        })
    }
    
    
}
