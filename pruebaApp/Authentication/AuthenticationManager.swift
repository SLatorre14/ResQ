//
//  AuthenticationManager.swift
//  pruebaApp
//
//  Created by IMAC on 19/03/24.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    
}

final class AuthenticationManager{
    static let shared = AuthenticationManager()
    private init() {}
    
    func getAuthenticatedUser() throws -> Bool {
        var auth = true
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
            
        }
        if user.email != nil{
          auth = false
        }
        return auth
    }
    
    func signUserOut() throws {
        try Auth.auth().signOut()
    }
    
 
}
