//
//  FirebaseAuthService.swift
//  price tracker
//
//  Created by Kris Skierniewski on 04/09/2025.
//

import FirebaseAuth

protocol AuthService {
    var currentUserId: String? { get }
    var currentUserEmailAddress: String? { get }
    func signIn(email: String, password: String, completion: @escaping ((Result<Void,Error>) -> Void))
    func createUser(email: String, password: String, completion: @escaping ((Result<Void,Error>) -> Void))
    func sendPasswordReset(with email: String, completion: @escaping ((Result<Void,Error>) -> Void))
    func signOut() -> Result<Void,Error>
    func deleteUser(_ completion: @escaping ((Result<Void, Error>) -> Void))
    func addStateDidChangeListener(onChange: @escaping (() -> Void)) -> AuthStateHandle
}

protocol AuthStateHandle {
    func remove()
}

class FirebaseAuthStateHandle: AuthStateHandle {
    private let handle: NSObjectProtocol
    init(handle: NSObjectProtocol) {
        self.handle = handle
    }
    
    func remove() {
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    deinit {
        remove()
    }
}

class FirebaseAuthService: AuthService {
    
    var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var currentUserEmailAddress: String? {
        return Auth.auth().currentUser?.email
    }
    
    func signIn(email: String, password: String, completion: @escaping ((Result<Void,Error>) -> Void)) {
        
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
    }
    
    func createUser(email: String, password: String, completion: @escaping ((Result<Void,Error>) -> Void)) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func sendPasswordReset(with email: String, completion: @escaping ((Result<Void,Error>) -> Void)) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func signOut() -> Result<Void,Error> {
        do {
            try Auth.auth().signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func deleteUser(_ completion: @escaping ((Result<Void, Error>) -> Void)) {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } else {
            completion(.failure(AuthenticationError.notSignedIn))
        }
    }
    
    func addStateDidChangeListener(onChange: @escaping (() -> Void)) -> AuthStateHandle {
        let handle = Auth.auth().addStateDidChangeListener { _, _ in
            onChange()
        }
        return FirebaseAuthStateHandle(handle: handle)
    }
}
