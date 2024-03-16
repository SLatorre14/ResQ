//
//  pruebaAppApp.swift
//  pruebaApp
//
//  Created by IMAC on 3/03/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct pruebaAppApp: App {
    init(){
        FirebaseApp.configure()
        print("Configured Firebase")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


