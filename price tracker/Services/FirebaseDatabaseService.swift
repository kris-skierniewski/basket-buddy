//
//  FirebaseDatabaseService.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2025.
//
import FirebaseDatabase

protocol ObserverHandle {
    func remove()
}

class FirebaseObserverHandle: ObserverHandle {
    private let database: DatabaseReference
    private let path: String
    private let handle: DatabaseHandle
    
    init(database: DatabaseReference, path: String, handle: DatabaseHandle) {
        self.database = database
        self.path = path
        self.handle = handle
    }
    
    func remove() {
        database.child(path).removeObserver(withHandle: handle)
    }
}

class FirebaseDatabaseService {
    private let database: DatabaseReference
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    init() {
        self.database = Database.database(url: "https://price-tracker-f4073-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    }
    
    func create<T: Codable>(_ item: T, at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try jsonEncoder.encode(item)
            let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            database.child(path).setValue(dictionary) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
            
        } catch {
            completion(.failure(error))
        }
    }
    
    func delete(at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        database.child(path).removeValue { error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func observe<T: Codable>(_ path: String, as type: T.Type, onChange: @escaping(T?) -> Void) -> ObserverHandle {
        let handle = database.child(path).observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                onChange(nil)
                return
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: value)
                let item = try JSONDecoder().decode(T.self, from: data)
                onChange(item)
            } catch {
                onChange(nil)
            }
        }
        return FirebaseObserverHandle(database: database, path: path, handle: handle)
        
    }
    
    func observeList<T: Codable>(_ path: String, as type: T.Type, onChange: @escaping([T]) -> Void) -> ObserverHandle {
        let handle = database.child(path).observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? [String: [String: Any]] else {
                onChange([])
                return
            }
            
            let items = dictionary.compactMap { (key, value) -> T? in
                var itemDictionary = value
                itemDictionary["id"] = key
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: itemDictionary)
                        let item = try JSONDecoder().decode(T.self, from: data)
                    
                    return item
                } catch {
                    return nil
                }
                
            }
            onChange(items)
        }
        return FirebaseObserverHandle(database: database, path: path, handle: handle)
    }
    
    func observeNestedUnkeyedList<T: Codable>(_ path: String, as type: T.Type, onChange: @escaping ([T]) -> Void) -> ObserverHandle {
        let handle = database.child(path).observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? [String: [String: [String: Any]]] else {
                onChange([])
                return
            }
            
            // Flatten out all price dictionaries across all productIds
            let items = dictionary.flatMap { (_, pricesForProduct) in //TODO: rename ?
                pricesForProduct.compactMap { (_, value) -> T? in
                    do {
                        let data = try JSONSerialization.data(withJSONObject: value)
                        return try JSONDecoder().decode(T.self, from: data)
                    } catch {
                        print("❌ Decode error: \(error)")
                        return nil
                    }
                }
            }
            
            onChange(items)
        }
        
        return FirebaseObserverHandle(database: database, path: path, handle: handle)
    }
    
    func update<T: Codable>(_ item: T, at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(item)
            let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            database.child(path).updateChildValues(dictionary ?? [:]) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
}
