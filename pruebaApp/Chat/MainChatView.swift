//
//  MainChatView.swift
//  pruebaApp
//
//  Created by IMAC on 22/03/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct RecentMessage: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let text, fromId, toId, email: String
    let timeStamp: Timestamp
    
    init(documentId: String, data: [String : Any]){
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp(date: Date())
       
    }
}

struct ChatUser: Identifiable {
    var id: String {uid}
    let uid, email: String
    init(email: String, uid: String){
        self.email = email
        self.uid = uid
    }
    
}

class MainChatViewModel: ObservableObject{
 
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
       
        
        fetchCurrentUser()
        
        fetchRecentMessages()
    }
    
    @Published var recentMessages = [RecentMessage]()
    
     var firestoreListener: ListenerRegistration?
    
    
    
     func fetchRecentMessages(){
         
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        
         
         firestoreListener?.remove()
         self.recentMessages.removeAll()
         
         
        firestoreListener = FirebaseManager.shared.firestore.collection("recent_messages").document(uid).collection("messages").order(by: "timeStamp").addSnapshotListener { querySnapshot, error in
            if let error = error{
                print(error)
                return
            }
            
            querySnapshot?.documentChanges.forEach({ change in
     
                let docId = change.document.documentID
            
                if let index = self.recentMessages.firstIndex(where: { rm in return rm.documentId == docId
                }) {
                    self.recentMessages.remove(at: index)
                }
                    
                self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
    
            })
        }
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
            self.chatUser = ChatUser(email: email, uid: userId)
            
        }
        
    }
    
}

struct MainChatView: View {
    @State var navigateToChat = false
    @ObservedObject  var vm = MainChatViewModel()
    
    private var chatViewModel = ChatViewModel(chatUser: nil)
    
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
                    ForEach(vm.recentMessages) { recentMessage in
                        
                        Button{
                            let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                            self.chatUser = ChatUser.init(email: recentMessage.email, uid: uid)
                            self.chatViewModel.chatUser = self.chatUser
                            self.chatViewModel.fetchMessages()
                            self.navigateToChat.toggle()
                        } label: {
                            HStack(spacing: 16){
                                Image(systemName: "person.fill")
                                    .foregroundColor(Color(.black))
                                    .font(.system(size: 32))
                                VStack(alignment: .leading) {
                                    Text(recentMessage.email)
                                        .foregroundColor(Color(.black))
                                    Text(recentMessage.text)
                                        .foregroundColor(Color(.lightGray))
                                        .multilineTextAlignment(.leading)
                                    
                                }
                                Spacer()
                                
                                
                                
                            }
                            
                        }
                        Divider()
                            .padding(.vertical, 8)
                        
                    }.padding(.horizontal)
                    
                }
                
                NavigationLink("", isActive: $navigateToChat){
              
                    ChatView(vm: chatViewModel)
                }
                
               
            
            
            }
            .overlay(newMessageButton, alignment: .bottom)
            .toolbar(.hidden)
            
            
        }.onAppear{
            vm.fetchCurrentUser()
            vm.fetchRecentMessages()
        }
        
    }
    @State var showCreateMessage = false
    
    private var newMessageButton: some View{
        
        Button {
            showCreateMessage.toggle()
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
            
        
        
        }
        .fullScreenCover(isPresented: $showCreateMessage){
            NewMessageView(didSelectUser: { user in
                print(user.email)
                self.navigateToChat.toggle()
                self.chatUser = user
                self.chatViewModel.chatUser = user
                self.chatViewModel.fetchMessages()
            })
        }
    }
    
    @State var chatUser: ChatUser?
}

struct MainChatView_Previews: PreviewProvider {
    static var previews: some View {
        MainChatView()
            .preferredColorScheme(.light)
    }
}
