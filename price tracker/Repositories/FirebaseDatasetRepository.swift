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

class FirebaseDatasetRepository {
    private let firebaseService: FirebaseDatabaseService
    private let userId: String
    
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
}
