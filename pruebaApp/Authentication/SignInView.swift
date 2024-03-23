//
//  SignInView.swift
//  pruebaApp
//
//  Created by IMAC on 19/03/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore


class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {

        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        
        super.init()
    }
}
    
  
    
    


final class SignInViewModel: ObservableObject{
   
    @Published var email = ""
    @Published var password = ""
    
}


var provider = OAuthProvider(providerID: "microsoft.com")
struct SignInView: View {
    
    
    @StateObject private var viewModel = SignInViewModel()
    @Binding var showSigninView: Bool
    var body: some View {
        VStack {
            TextField("Email:", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Password:", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button{
            } label: {
                Text("Sign in")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: {
                initiateMicrosoftAuthentication()
               
            }) {
                Text("Sign in with Microsoft")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
            }
            
           
            
            
            
            
            .padding()
            .navigationTitle("Sign In with Email")
        }
        
        
    }
    
    private func initiateMicrosoftAuthentication() {
        
        
        // Set scopes if needed
        provider.scopes = ["email", "profile"] // Add additional scopes as needed
        
        // Get credential with email
        provider.getCredentialWith(nil) { credential, error in
            if let error = error {
                // Handle error
                print("Error:", error.localizedDescription)
                return
            }
            if let credential = credential {
                // Sign in with credential
                
                FirebaseManager.shared.auth.signIn(with: credential) { authResult, error in
                    if let error = error {
                        // Handle sign-in error
                        print("Sign-in Error:", error.localizedDescription)
                        return
                    }
                    // User signed in successfully
                    print("User signed in:", authResult?.user.uid ?? "No user")
                    showSigninView = false
                    storeUserInformation()
            
                    return
            
                }
            }
        }
    }
    
    private func storeUserInformation(){
        let userEmail = FirebaseManager.shared.auth.currentUser?.email
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            return}
        let userData =  ["email":  userEmail, "uid": userId ]
        FirebaseManager.shared.firestore.collection("users").document(userId).setData(userData) {
            err in
            if let err = err{
                print(err)
                return
            }
            print("Success")
            
        }
        
     
    }
    
    
    struct SignInView_Previews: PreviewProvider {
        static var previews: some View {
            SignInView(showSigninView: .constant(true))
            
        }
    }
}
