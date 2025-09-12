//
//  MockDatasetRepository.swift
//  price tracker
//
//  Created by Kris Skierniewski on 12/09/2025.
//
@testable import price_tracker

class MockDatasetRepository: DatasetRepository {
    
    var mockUserId: String = ""
    var mockDatasets: [Dataset] = []
    var mockUserDatasetId: String?
    
    var onUserDatasetIdChangedCallbacks: [(String?) -> Void] = []
    var onDatasetChangedCallbacks: [String: [(Dataset?) -> Void]] = [:]
    
    func getUserDatasetId(completion: @escaping (Result<String?, any Error>) -> Void) {
        completion(.success(mockUserDatasetId))
    }
    
    func observeUserDatasetId(onChange: @escaping (String?) -> Void) -> any ObserverHandle {
        onUserDatasetIdChangedCallbacks.append(onChange)
        onChange(mockUserDatasetId)
        return MockObserverHandle()
    }
    
    func updateUserDatasetId(_ datasetId: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        mockUserDatasetId = datasetId
        triggerUserDatasetIdObservers()
        completion(.success(()))
    }
    
    func getDataset(withId datasetId: String, completion: @escaping (Result<Dataset?, any Error>) -> Void) {
        let matchingDataset = mockDatasets.first(where: { $0.id == datasetId })
        completion(.success(matchingDataset))
    }
    
    func observeDataset(withId datasetId: String, onChange: @escaping (Dataset?) -> Void) -> any ObserverHandle {
        var callbacks = onDatasetChangedCallbacks[datasetId] ?? []
        callbacks.append(onChange)
        onDatasetChangedCallbacks[datasetId] = callbacks
        let matchingDataset = mockDatasets.first(where: { $0.id == datasetId })
        onChange(matchingDataset)
        return MockObserverHandle()
    }
    
    func updateDataset(_ dataset: Dataset, completion: @escaping (Result<Void, any Error>) -> Void) {
        if let matchingDatasetIndex = mockDatasets.firstIndex(where: { $0.id == dataset.id }) {
            mockDatasets[matchingDatasetIndex] = dataset
            triggerDatasetObservers(for: dataset.id)
        }
        completion(.success(()))
    }
    
    func setupUserDataset(completion: @escaping (Result<String, any Error>) -> Void) {
        let newDataset = Dataset(id: UUID().uuidString, members: [mockUserId: true])
        mockUserDatasetId = newDataset.id
        mockDatasets.append(newDataset)
        triggerDatasetObservers(for: newDataset.id)
        triggerUserDatasetIdObservers()
        completion(.success((newDataset.id)))
    }
    
    func joinDataset(withId datasetId: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        var matchingDataset = mockDatasets.first(where: { $0.id == datasetId })
        matchingDataset?.members = [mockUserId: true]
        mockUserDatasetId = datasetId
        triggerDatasetObservers(for: datasetId)
        triggerUserDatasetIdObservers()
        completion(.success(()))
    }
    
    func triggerDatasetObservers(for id: String) {
        let callBacks = onDatasetChangedCallbacks[id] ?? []
        let dataset = mockDatasets.first(where: { $0.id == id })
        
        callBacks.forEach({
            $0(dataset)
        })
    }
    
    func triggerUserDatasetIdObservers() {
        onUserDatasetIdChangedCallbacks.forEach({
            $0(mockUserDatasetId)
        })
    }
    
    
}
