//
//  MainChatView.swift
//  pruebaApp
//
//  Created by IMAC on 22/03/24.
//

import SwiftUI

struct ChatUser{
    let uid, email: String
    
    
}

class MainChatViewModel: ObservableObject{
 
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
       
        
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        
        guard let userId =
        FirebaseManager.shared.auth.currentUser?.uid else { return }
   
        
        FirebaseManager.shared.firestore.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user : ", error)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            print(data)
            let userId = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            self.chatUser = ChatUser(uid: userId, email: email)
            
        }
        
    }
    
}

struct MainChatView: View {
    @ObservedObject  var vm = MainChatViewModel()
    
    var body: some View {
        NavigationView{
            VStack{
                
                
                HStack{
                    
                    Image(systemName: "person.fill")
                        .foregroundColor(Color(.black))
                        .font(.system(size: 34, weight: .heavy))
                    
                    VStack(alignment:  .leading, spacing: 4){
                        let email = vm.chatUser?.email.replacingOccurrences(of: "@uniandes.edu.co", with: "") ?? ""
                        Text(email)
                            .foregroundColor(Color(.black))
                            .font(.system(size: 32, weight: .bold))
                 
                        HStack{
                            Circle()
                                .foregroundColor(Color("LightGreen"))
                                .frame(width: 14, height: 14)
                            
                            Text("Online")
                                .font(.system(size:12))
                                .foregroundColor(Color(.lightGray))
                        }
                        
                    }
                    Spacer()
                }
              
                .padding()
                
                ScrollView{
                    ForEach(0..<10, id: \.self) { num in
                        HStack(spacing: 16){
                            Image(systemName: "person.fill")
                                .foregroundColor(Color(.black))
                                .font(.system(size: 32))
                            VStack(alignment: .leading) {
                                Text("Username")
                                    .foregroundColor(Color(.black))
                                Text("Message sent to user")
                                    .foregroundColor(Color(.lightGray))
                                
                            }
                            Spacer()
                            
                            Text("22d")
                                .foregroundColor(Color(.black))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Divider()
                            .padding(.vertical, 8)
                        
                    }.padding(.horizontal)
                    
                }
                
               
            
            
            }
            .overlay(
                Button {
                    
                } label: {
                    HStack{
                        Spacer()
                        Text("+ New message")
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(.vertical)
                    
                    .background(Color("LightGreen"))
                    .cornerRadius(32)
                    .padding(.horizontal)
                    .shadow(radius: 15)
                    
                
                
                }, alignment: .bottom)
            .toolbar(.hidden)
            
            
        }.onAppear{
            vm.fetchCurrentUser()
        }
        
    }
}

struct MainChatView_Previews: PreviewProvider {
    static var previews: some View {
        MainChatView()
            .preferredColorScheme(.light)
    }
}
