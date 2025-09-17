//
//  DatasetRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 11/09/2025.
//


struct Dataset: Codable, Equatable {
    let id: String
    var members: [String: Bool]
    
}

protocol DatasetRepository {
    func getUserDatasetId(completion: @escaping (Result<String?, Error>) -> Void)
    func observeUserDatasetId(onChange: @escaping (String?) -> Void) -> any ObserverHandle
    func updateUserDatasetId(_ datasetId: String, completion: @escaping (Result<Void, any Error>) -> Void)
    func getDataset(withId datasetId: String, completion: @escaping(Result<Dataset?, Error>) -> Void)
    func observeDataset(withId datasetId: String, onChange: @escaping (Dataset?) -> Void) -> any ObserverHandle
    func updateDataset(_ dataset: Dataset, completion: @escaping (Result<Void, any Error>) -> Void)
    func setupUserDataset(completion: @escaping(Result<String,Error>) -> Void)
    func joinDataset(withId datasetId: String, completion: @escaping (Result<Void, any Error>) -> Void)
    
    func deleteDataset(withId datasetId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteUserFromDataset(datasetId: String, userId: String, completion:  @escaping (Result<Void, Error>) -> Void)
    //var userDatasetId: String? { get }
}

class FirebaseDatasetRepository: DatasetRepository {
    private let firebaseService: FirebaseDatabaseService
    private let userId: String
    
    //var userDatasetId: String?
    
    init(firebaseService: FirebaseDatabaseService, userId: String) {
        self.firebaseService = firebaseService
        self.userId = userId
    }
    
    func getUserDatasetId(completion: @escaping (Result<String?, Error>) -> Void) {
        let path = "userDataset/\(userId)"
        firebaseService.getValue(path, as: String.self, completion: completion)
    }
    
    func observeUserDatasetId(onChange: @escaping (String?) -> Void) -> any ObserverHandle {
        let path = "userDataset/\(userId)"
        return firebaseService.observe(path, as: String.self, onChange: onChange)
    }
    
    func updateUserDatasetId(_ datasetId: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        let path = "userDataset/\(userId)"
        firebaseService.update(datasetId, at: path, completion: completion)
    }
    
    func getDataset(withId datasetId: String, completion: @escaping(Result<Dataset?, Error>) -> Void) {
        let path = "datasets/\(datasetId)/publicInfo"
        firebaseService.getValue(path, as: Dataset.self, completion: completion)
    }
    
    func observeDataset(withId datasetId: String, onChange: @escaping (Dataset?) -> Void) -> any ObserverHandle {
        let path = "datasets/\(datasetId)/publicInfo"
        return firebaseService.observe(path, as: Dataset.self, onChange: onChange)
    }
    
    func updateDataset(_ dataset: Dataset, completion: @escaping (Result<Void, any Error>) -> Void) {
        let path = "datasets/\(dataset.id)/publicInfo"
        firebaseService.update(dataset, at: path, completion: completion)
    }
    
    func setupUserDataset(completion: @escaping(Result<String,Error>) -> Void) {
        
        let datasetId = UUID().uuidString
        let dataset = Dataset(id: datasetId, members: [userId: true])
        
        let updates: [String: Codable] = [
            "datasets/\(datasetId)/publicInfo": dataset,
            "userDataset/\(userId)": datasetId
        ]
        
        firebaseService.updateMultiple(updates) { result in
            switch result {
            case .success(()):
                completion(.success(datasetId))
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    func joinDataset(withId datasetId: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        let updates: [String: Codable] = [
            "datasets/\(datasetId)/publicInfo/members/\(userId)": true,
            "userDataset/\(userId)": datasetId
        ]
        
        firebaseService.updateMultiple(updates) { result in
            switch result {
            case .success(()):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    func deleteUserFromDataset(datasetId: String, userId: String, completion:  @escaping (Result<Void, Error>) -> Void) {
        let updates: [String: Any] = [
            "datasets/\(datasetId)/publicInfo/members/\(userId)": NSNull(),
            "userDataset/\(self.userId)": NSNull()
        ]
        
        firebaseService.updateMultiple(updates, completion: completion)
    }
    
    func deleteDataset(withId datasetId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let datasetPath = "datasets/\(datasetId)"
        firebaseService.delete(at: datasetPath) { result in
            switch result {
            case .success():
                let userDatasetPath = "userDataset/\(self.userId)"
                self.firebaseService.delete(at: userDatasetPath, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
