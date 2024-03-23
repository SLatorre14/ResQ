//
//  pruebaAppApp.swift
//  pruebaApp
//
//  Created by IMAC on 3/03/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@main
struct pruebaAppApp: App {
    init() {
       
            FirebaseApp.configure()
            print("Firebase configured")
           
        }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}




