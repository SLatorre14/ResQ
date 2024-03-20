//
//  RootView.swift
//  pruebaApp
//
//  Created by IMAC on 20/03/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    var body: some View {
        ZStack {
            NavigationStack{
                Text("Settings")
            }
        }
        .onAppear{
            let auth = try? AuthenticationManager.shared.getAuthenticatedUser()
            self .showSignInView = auth ?? true
            print(auth)
        }
        .fullScreenCover(isPresented: $showSignInView){
            NavigationStack {
                SignInView()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
