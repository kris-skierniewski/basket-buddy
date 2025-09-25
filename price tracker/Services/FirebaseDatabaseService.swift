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
    
    private var isConnectedObserver: ObserverHandle?
    private var isConnected: Bool = true//false
    
    init() {
        let database = Database.database(url: "https://price-tracker-f4073-default-rtdb.europe-west1.firebasedatabase.app/")
        if database.isPersistenceEnabled == false {
            database.isPersistenceEnabled = true
        }
        self.database = database.reference()
        isConnectedObserver = observeConnection()
    }
    
    func observeConnection() -> ObserverHandle {
        let path = ".info/connected"
        let handle = database.child(path).observe(.value) { [weak self] snapshot in
            if let connected = snapshot.value as? Bool {
                self?.isConnected = connected
            } else {
                self?.isConnected = false
            }
        }
        return FirebaseObserverHandle(database: database, path: path, handle: handle)
    }
    
    func updateMultiple(_ updates: [String: Any], completion: @escaping(Result<Void, Error>) -> Void) {
        var encodedUpdates: [String: Any] = [:]
        for update in updates {
            if isBasicType(update.value) {
                encodedUpdates[update.key] = update.value
            } else if update.value is NSNull {
                encodedUpdates[update.key] = NSNull()
            } else if let codableValue = update.value as? Codable { //must be struct
                do {
                    let data = try jsonEncoder.encode(codableValue)
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let dictionary = dictionary {
                        encodedUpdates[update.key] = dictionary
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(RepositoryError.notEncodable))
            }
        }
        
        database.updateChildValues(encodedUpdates) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func create<T: Codable>(_ item: T, at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try jsonEncoder.encode(item)
            let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if !isConnected {
                database.child(path).setValue(dictionary)
                completion(.success(()))
            } else {
                database.child(path).setValue(dictionary) { error, _ in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
            
        } catch {
            completion(.failure(error))
        }
    }
    
    func delete(at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if !isConnected {
            database.child(path).removeValue()
            completion(.success(()))
        } else {
            database.child(path).removeValue { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func getList<T: Codable>(_ path: String, as type: T.Type, completion: @escaping(Result<[T],Error>) -> Void) {
        database.child(path).observeSingleEvent(of: .value, with: { snapshot in
            guard let dictionary = snapshot.value as? [String: [String: Any]] else {
                completion(.success([]))
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
            completion(.success(items))
        }, withCancel: { error in
            completion(.failure(error))
        })
    }
    
    func getValue<T:Codable>(_ path: String, as type: T.Type, completion: @escaping(Result<T?,Error>) -> Void) {
        database.child(path).observeSingleEvent(of: .value, with: { snapshot in
            guard let nonNilValue = snapshot.value else {
                completion(.success(nil))
                return
            }
            if let decodedValue = nonNilValue as? T {
                completion(.success(decodedValue))
                return
            }
            guard let value = nonNilValue as? [String: Any] else {
                
                completion(.success(nil))
                return
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: value)
                let item = try JSONDecoder().decode(T.self, from: data)
                completion(.success(item))
            } catch {
                completion(.success(nil))
            }
        }, withCancel: { error in
            completion(.failure(error))
        })
    }
    
    func observe<T: Codable>(_ path: String, as type: T.Type, onChange: @escaping(T?) -> Void) -> ObserverHandle {
        let handle = database.child(path).observe(.value) { snapshot in
            guard let nonNilValue = snapshot.value else {
                onChange(nil)
                return
            }
            
            if let decodedValue = nonNilValue as? T {
                onChange(decodedValue)
                return
            }
            
            guard let value = nonNilValue as? [String: Any] else {
                
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
            if !isConnected {
                database.child(path).updateChildValues(dictionary ?? [:])
                completion(.success(()))
            } else {
                database.child(path).updateChildValues(dictionary ?? [:]) { error, _ in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateItems(_ items: [String: Any], at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var flattenedItems = items
        
        if let nestedItems = items as? [String: [String: Any]] {
            flattenedItems = flattenItems(nestedItems)
        }
        
        var updates: [String: Any] = [:]
        
        do {
            for item in flattenedItems {
                if isBasicType(item.value) {
                    updates[item.key] = item.value
                } else if item.value is NSNull {
                    updates[item.key] = NSNull()
                } else if let encodable = item.value as? Codable { //must be struct
                    let data = try jsonEncoder.encode(encodable)
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let dictionary = dictionary {
                        updates[item.key] = dictionary
                    }
                } else {
                    throw(RepositoryError.notEncodable)
                }
            }
            
        } catch {
            completion(.failure(error))
            return
        }
        
        database.child(path).updateChildValues(updates) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
    }
    
    private func flattenItems(_ items: [String: [String : Any]]) -> [String: Any] {
        var flattenedItems = [String: Any]()
        for (key, value) in items {
            for (nestedKey, nestedValue) in value {
                let path = "\(key)/\(nestedKey)"
                flattenedItems[path] = nestedValue
            }
            
        }
        return flattenedItems
    }
    
    private func isBasicType(_ value: Any) -> Bool {
        return value is String ||
               value is Int ||
               value is Double ||
               value is Float ||
               value is Bool ||
               value is NSNumber ||
               value is NSString
    }
    
}
