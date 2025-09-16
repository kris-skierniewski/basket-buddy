//
//  FirebaseUserRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 12/09/2025.
//

protocol UserRepository {
    func updateUser(_ user: User, completion: @escaping (Result<Void, Error>) -> Void)
    func observeUser(withId userId: String, onChange: @escaping (User?) -> Void) -> ObserverHandle
    func deleteUser(_ user: User, completion: @escaping (Result<Void, Error>) -> Void)
    func observeUsers(onChange: @escaping ([User]) -> Void) -> ObserverHandle
}

class FirebaseUserRepository: UserRepository {
  
    private let firebaseService: FirebaseDatabaseService
    
    init(firebaseService: FirebaseDatabaseService) {
        self.firebaseService = firebaseService
    }
    
    func updateUser(_ user: User, completion: @escaping (Result<Void, any Error>) -> Void) {
        let path = "users/\(user.id)"
        firebaseService.update(user, at: path, completion: completion)
    }
    
    func observeUser(withId userId: String, onChange: @escaping (User?) -> Void) -> any ObserverHandle {
        let path = "users/\(userId)"
        return firebaseService.observe(path, as: User.self, onChange: onChange)
    }
    
    func deleteUser(_ user: User, completion: @escaping (Result<Void, any Error>) -> Void) {
        let path = "users/\(user.id)"
        firebaseService.delete(at: path, completion: completion)
    }
    
    func observeUsers(onChange: @escaping ([User]) -> Void) -> any ObserverHandle {
        let path = "users"
        return firebaseService.observeList(path, as: User.self, onChange: onChange)
    }
    
}
