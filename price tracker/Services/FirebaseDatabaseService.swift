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
        Database.database().isPersistenceEnabled = true
    }
    
    func updateMultiple(_ updates: [String: any Codable], completion: @escaping(Result<Void, Error>) -> Void) {
        var encodedUpdates: [String: Any] = [:]
        for update in updates {
            if isBasicType(update.value) {
                encodedUpdates[update.key] = update.value
            } else { //must be struct
                do {
                    let data = try jsonEncoder.encode(update.value)
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let dictionary = dictionary {
                        encodedUpdates[update.key] = dictionary
                    }
                } catch {
                    completion(.failure(error))
                }
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
    
    func getValue<T:Codable>(_ path: String, as type: T.Type, completion: @escaping(Result<T?,Error>) -> Void) {
        database.child(path).getData { error, snapshot in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let nonNilValue = snapshot?.value else {
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
                    completion(.failure(error))
                }
            }
        }
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
