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
    private let datasetId: String
    
    init(firebaseService: FirebaseDatabaseService, datasetId: String) {
        self.firebaseService = firebaseService
        self.datasetId = datasetId
    }
    
    func updateUserPreferences(_ prefs: UserPreferences, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "datasets/\(datasetId)/preferences"
        firebaseService.update(prefs, at: path, completion: completion)
    }
    
    func deleteUserPreferences(completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "datasets/\(datasetId)/preferences"
        firebaseService.delete(at: path, completion: completion)
    }
    
    func observePreferences(onChange: @escaping (UserPreferences?) -> Void) -> ObserverHandle {
        let path = "datasets/\(datasetId)/preferences"
        return firebaseService.observe(path, as: UserPreferences.self, onChange: onChange)
    }
    
}
