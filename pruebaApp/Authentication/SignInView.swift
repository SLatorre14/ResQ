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
    
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                completion(.failure(NSError(domain: "com.yourapp.error", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
                return
            }
            
            let fileName = UUID().uuidString + ".jpg"
            let storageRef = storage.reference().child("images").child(fileName)
            
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let downloadURL = url else {
                        completion(.failure(NSError(domain: "com.yourapp.error", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve download URL"])))
                        return
                    }
                    
                    completion(.success(downloadURL))
                }
            }
        }
    
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
    @State var loginStatusMessage = ""
    @Published var rememberCredentials = false
    
    private let firebaseManager: FirebaseManager
        
        init(firebaseManager: FirebaseManager = FirebaseManager.shared) {
            self.firebaseManager = firebaseManager
            loadSavedCredentials()
        }
    
    private func saveCredentials() {
            UserDefaults.standard.set(email, forKey: "savedEmail")
            UserDefaults.standard.set(password, forKey: "savedPassword")
        }
    
    private func eraseCredentials() {
        UserDefaults.standard.removeObject(forKey: "savedEmail")
        UserDefaults.standard.removeObject(forKey: "savedPassword")
    }
    
    private func loadSavedCredentials() {
            if let savedEmail = UserDefaults.standard.string(forKey: "savedEmail"),
               let savedPassword = UserDefaults.standard.string(forKey: "savedPassword") {
                email = savedEmail
                password = savedPassword
                rememberCredentials = true // Marcar que se están recordando las credenciales
            }
        }
    
    
    
    func loginUser(completion: @escaping (Bool, String?) -> Void) {
        if rememberCredentials {
                    saveCredentials()
        } else{
            eraseCredentials()
        }
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, error in
                if let error = error{
                    let errorMessage = "Failed to log user: \(error)"
                    self.loginStatusMessage = errorMessage
                    print(errorMessage)
                    completion(false, errorMessage)
                    return
                    
                }
            
                print("Success logging in user: \(result?.user.uid ?? "")")
            
                completion(true, nil)
                
        }
        
    }
    
    func createNewAccount(completion: @escaping (Bool, String?) -> Void) {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password){ result, error in
            if let error = error{
                let errorMessage = "Failed to log user: \(error)"
                self.loginStatusMessage = errorMessage
                print(errorMessage)
                completion(false, errorMessage)
                return
                
            }
            
            print("Success creating in user: \(result?.user.uid ?? "")")
            completion(true, nil)
        }
    }
    
}




var provider = OAuthProvider(providerID: "microsoft.com")
struct SignInView: View {
    
    var isPasswordValid: Bool {
            let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{6,}$"
            let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
            return passwordPredicate.evaluate(with: viewModel.password)
        }
    
    var isPasswordLengthValid: Bool {
            return viewModel.password.count >= 6
        }
        
        var isUppercasePresent: Bool {
            return viewModel.password.rangeOfCharacter(from: .uppercaseLetters) != nil
        }
        
        var isLowercasePresent: Bool {
            return viewModel.password.rangeOfCharacter(from: .lowercaseLetters) != nil
        }
        
        var isNumberPresent: Bool {
            return viewModel.password.rangeOfCharacter(from: .decimalDigits) != nil
        }
        
    
    @State var showAlert = false
    @State var errorMessage = ""
    @State var showImagePicker = false
    @State var loginStatusMessage = ""
    @State var isLoginMode = false
    @StateObject private var viewModel = SignInViewModel()
    @Binding var showSigninView: Bool
    var body: some View {
        NavigationView{
            ScrollView{
                
                VStack{
                    Picker(selection: $isLoginMode, label: Text("")){
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                        
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding()
                    
                   
                    Button{
                        showImagePicker.toggle()
                    } label: {
                        
                        VStack{
                            if let image = self.image{
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 128, height: 128)
                                    .cornerRadius(64)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size:60))
                                    .padding()
                            }
                        }
                        
                    }
                    
                    
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .cornerRadius(10)
                        .onAppear {
                            viewModel.email = UserDefaults.standard.string(forKey: "savedEmail") ?? ""
                        }
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(10)
                        .onAppear {
                         viewModel.password = UserDefaults.standard.string(forKey: "savedPassword") ?? ""
                        }
                    
                    Toggle("Remember Credentials", isOn: $viewModel.rememberCredentials)
                                           .padding()
                                           .foregroundColor(.black)
                            
                    Button{
                        handleAction()
                    } label: {
                        HStack{
                          
                            Text(isLoginMode ?  "Log In" : "Create Account")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 55)
                                .frame(width: 250)
                                .background(Color("LightGreen" ))
                                .cornerRadius(10)
                        }
                        .disabled((!isPasswordValid) && (!isLoginMode))
                        .opacity((!isPasswordValid && !isLoginMode) ? 0.5 : 1.0)
                    }
                    
                    if isLoginMode{
                        Button(action: {
                            initiateMicrosoftAuthentication()
                           
                        }) {
                            
                            Text("Sign in with Microsoft")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 55)
                                .frame(width: 250)
                                .background(Color("LightGreen"))
                                .cornerRadius(10)
                        }
                    }
                    
                    
                }
                .padding()
                
                if !isLoginMode{
                    VStack {
                        
                        Text("Password must contain:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                        Image(systemName: isPasswordLengthValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isPasswordLengthValid ? .green : .red)
                        Text("At least 6 characters")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Image(systemName: isUppercasePresent ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isUppercasePresent ? .green : .red)
                        Text("An uppercase letter")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Image(systemName: isLowercasePresent ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isLowercasePresent ? .green : .red)
                        Text("A lowercase letter")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Image(systemName: isNumberPresent ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isNumberPresent ? .green : .red)
                        Text("A number")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                       
                        
                        
                    }
                }
                
                
                if !errorMessage.isEmpty {
                   
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
            }.navigationTitle(isLoginMode ? "Log In": "Create Account")
            
        }.fullScreenCover(isPresented: $showImagePicker, onDismiss: nil){
            ImagePicker(image: $image)
        }
        
        
       
        
        
    }
    @State var image: UIImage?
    
    private func handleAction() {
        if isLoginMode {
                viewModel.loginUser() { success, message in
                    if success {
                        showSigninView = false
                        print("Aqui  NOOO")
                        storeUserInformation()
                    } else {
                        print("Aqui")
                        errorMessage = message ?? ""
                        showSigninView = true
                    }
                }
            } else {
                viewModel.createNewAccount() { success, message in
                    if success {
                        showSigninView = false
                        storeUserInformation()
                    } else {
                        errorMessage = message ?? ""
                        showSigninView = true
                    }
                }
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
