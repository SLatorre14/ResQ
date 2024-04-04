//
//  NewMessageView.swift
//  pruebaApp
//
//  Created by IMAC on 30/03/24.
//

import SwiftUI

class NewMessageViewModel: ObservableObject{
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init(){
        fetchAllUsers()
    }
    
    private func fetchAllUsers(){
        FirebaseManager.shared.firestore.collection("users").getDocuments {
            documentsSnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch users: \(error)"
                print("Failed to fetch users: \(error)")
                return
            }
            
            documentsSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                let userId = data["uid"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                if userId !=
                    FirebaseManager.shared.auth.currentUser?.uid{
                    self.users.append(ChatUser(email: email, uid: userId))
                }
                
            })
        }
    }
}



struct NewMessageView: View {
    let didSelectUser: (ChatUser) -> ()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = NewMessageViewModel()
    var body: some View {
        NavigationView{
            ScrollView{
                Text(vm.errorMessage)
                ForEach(vm.users) { user in
                    Button{
                        presentationMode.wrappedValue.dismiss()
                        didSelectUser(user)
                    } label: {
                        HStack{
                            Text(user.email)
                                .foregroundColor(.black)
                        }.padding(.horizontal)
                        Divider()
                            .padding(.vertical, 8)
                    }
                    
                    
                    
                }
            }.navigationTitle("New Message")
                .toolbar{
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainChatView()
    }
}
