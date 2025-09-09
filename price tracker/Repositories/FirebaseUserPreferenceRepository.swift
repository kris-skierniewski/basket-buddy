//
//  FirebaseUserPreferenceRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

protocol UserPreferenceRepository {
    func updateUserPreferences(_ prefs: UserPreferences, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteUserPreferences(completion: @escaping (Result<Void, Error>) -> Void)
    func observePreferences(onChange: @escaping (UserPreferences?) -> Void) -> ObserverHandle
}

class FirebaseUserPreferenceRepository: UserPreferenceRepository {
    private let firebaseService: FirebaseDatabaseService
    private let userPath: String
    
    init(firebaseService: FirebaseDatabaseService, userId: String) {
        self.firebaseService = firebaseService
        self.userPath = userId
    }
    
    func updateUserPreferences(_ prefs: UserPreferences, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "preferences/\(userPath)"
        firebaseService.update(prefs, at: path, completion: completion)
    }
    
    func deleteUserPreferences(completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "preferences/\(userPath)"
        firebaseService.delete(at: path, completion: completion)
    }
    
    func observePreferences(onChange: @escaping (UserPreferences?) -> Void) -> ObserverHandle {
        let path = "preferences/\(userPath)"
        return firebaseService.observe(path, as: UserPreferences.self, onChange: onChange)
    }
    
}
