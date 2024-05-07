

import SwiftUI
import Firebase
import FirebaseFirestore


struct ChatMessage: Identifiable{
    
    var id: String { documentId }
    let fromId, toId, text: String
    let documentId: String
    
    init(documentId:String, data: [String:Any]){
        
        self.documentId = documentId
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
    }
}

class ChatViewModel: ObservableObject{
    @Published var messageText = ""
    @Published var selectedImage: UIImage?
    @Published var chatMessages = [ChatMessage]()
    @Published var cachedMessage: String = ""
    @Published var mergedMessages = [ChatMessage]()
    
    var isMessageTextEmpty: Bool{
        return messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?, selectedImage: UIImage? = nil){
        self.chatUser = chatUser
        self.selectedImage = selectedImage
        fetchMessages()
        loadMessageCache()
        print(cachedMessage)
        
    }
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore.collection("messages").document(fromId).collection(toId).order(by: "timeStamp").addSnapshotListener{ querySnapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            
            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added{
                    
                    let data = change.document.data()
                    self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                }
            })
            
            DispatchQueue.main.async {
                self.count += 1
            }
            
        }
        
        
    }
    
    func sendMessage()  {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        guard let toId = chatUser?.uid else { return }
        
        if let image = selectedImage{
            FirebaseManager.shared.uploadImage(image: image) { result in
                switch result {
                case .success(let imageURL):
                    // Once image is uploaded, send message with image URL
                    let messageData = [
                        "fromId": fromId,
                        "toId": toId,
                        "imageURL": imageURL,
                        "timeStamp": Timestamp()
                    ] as [String: Any]
                    
                    let document = FirebaseManager.shared.firestore.collection("messages").document(fromId).collection(toId).document()
                    document.setData(messageData) { error in
                        if let error = error {
                            print(error)
                            return
                        }
                        print("Succesfully sent image message")
                        self.persistRecentMessage(messageText: self.messageText)
                        self.selectedImage = nil // Reset selected image
                    }
                    
                    print("Image uploaded successfully: \(imageURL)")
                case .failure(let error):
                    // Handle failure
                    print("Failed to upload image: \(error)")
                }
                
            }
            
            
            
            
        } else {
            
            let document = FirebaseManager.shared.firestore.collection("messages").document(fromId).collection(toId).document()
            let messageData = ["fromId": fromId, "toId": toId, "text": self.messageText, "timeStamp": Timestamp()] as [String : Any]
            document.setData(messageData){ error in
                if let error = error {
                    print(error)
                    return
                }
                
                print("Succesfully sent message")
                
                self.persistRecentMessage(messageText: self.messageText)
                self.messageText = ""
                self.count += 1
                
                
            }
            
            let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages").document(toId).collection(fromId).document()
            
            recipientMessageDocument.setData(messageData){ error in
                if let error = error {
                    print(error)
                    return
                }
                
                print("Received Message")
                
            }
        }
        
        
        
    }
    
    
    
    func saveMessagesCache() {
        if !isMessageTextEmpty {
            cachedMessage = messageText
            messageText = "" // Reset message text after saving
            self.count += 1
        }
        UserDefaults.standard.set(cachedMessage, forKey: "unsentMessage")
        
        
        
    }
    
    func loadMessageCache(){
        cachedMessage = UserDefaults.standard.array(forKey: "unsentMessage") as? String ?? ""
    }
    
   
    
    func retrySendingMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        
        let document = FirebaseManager.shared.firestore.collection("messages").document(fromId).collection(toId).document()
        let messageData = ["fromId": fromId, "toId": toId, "text": cachedMessage, "timeStamp": Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print("Error sending message from cache:", error)
                return
            }
            
            print("Successfully sent message from cache")
            self.persistRecentMessage(messageText: self.cachedMessage)
            
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages").document(toId).collection(fromId).document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print("Error receiving message from cache:", error)
                return
            }
            print("Received Message from cache")
        }
            
        
        
        // After retrying, remove unsent messages from UserDefaults and reset cachedMessages
        UserDefaults.standard.removeObject(forKey: "unsentMessage")
        
        
        
    }

    
        
        
    
    private func persistRecentMessage(messageText: String){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        guard let uemail = FirebaseManager.shared.auth.currentUser?.email
        else { return }
        
        guard let toid = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection("recent_messages").document(uid).collection("messages").document(toid)
        
        let data = [
            "timeStamp": Timestamp(),
            "text": messageText,
            "fromId": uid,
            "toId": toid,
            "emailSender": chatUser!.email,
            "emailReceiver": uemail
        
        ] as [String : Any]
        
        document.setData(data) { error in
            if let error = error{
                print(error)
                return
            }
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("recent_messages").document(toid).collection("messages").document(uid)
        
        let dataRecipient = [
            "timeStamp": Timestamp(),
            "text": self.messageText,
            "fromId": toid,
            "toId": uid,
            "emailSender": chatUser!.email,
            "emailReceiver": uemail
        ] as [String : Any]
        
        recipientMessageDocument.setData(dataRecipient) { error in
            if let error = error{
                print(error)
                return
            }
        }
        
        
        cachedMessage = ""
    }
    
    
    @Published var count = 0
    
}

struct ChatView: View {
    @State var selectedImage: UIImage?
    @State var image: UIImage?
    @State var messages: [String] = []
    @State var showImagePicker = false
    @ObservedObject var monitor = NetworkMonitor()
    @ObservedObject var vm: ChatViewModel
   
    
    var body: some View {
        VStack {
            HStack {
                let email = vm.chatUser?.email.replacingOccurrences(of: "@uniandes.edu.co", with: "") ?? "Brigadier"
                Text(email)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color("LighterGreen"))
            }
            
            
            ScrollView {
                ScrollViewReader{ scrollViewProxy in
                    VStack{
                        ForEach(vm.chatMessages){ message in
                            VStack{
                                if message.fromId == FirebaseManager.shared.auth.currentUser?.uid{
                                    HStack {
                                        Spacer()
                                        HStack{
                                            Text(message.text)
                                                .foregroundColor(Color.white)
                                                
                                        }
                                        .padding()
                                        .background(Color("LighterGreen"))
                                        .cornerRadius(20)
                                        .padding(.horizontal, 16)
                                    }
                                } else {
                                    
                                    HStack(alignment: .top) {
                                        HStack{
                                            Text(message.text)
                                                .foregroundColor(Color.black)
                                        }
                                        
                                        .padding()
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(20)
                                        .padding(.horizontal, 16)
                                   
                                        Spacer()
                                    }

                                }
                                
                            }
                            
                        }
                        
                        HStack{
                            if !vm.cachedMessage.isEmpty{
                                HStack(alignment: .bottom){
                                    
                                    VStack{
                                        Text(vm.cachedMessage)
                                            .foregroundColor(Color.white)
                                    }
                                    .padding()
                                    .background(Color("LighterGreen"))
                                    .cornerRadius(20)
                                    
                                    
                                    Button{ vm.retrySendingMessages()
                                        
                                    }label: {
                                        Image(systemName: "arrow.clockwise.circle")
                                            .foregroundColor(.red) // Customize the color as needed
                                            .font(.system(size: 24)) // Customize the size as needed
                                    }
                                }
                             
                                
                            }
                            
                            

                            
                        }
                        
                     
                        
                        
                        
                        HStack{
                            Spacer()
                        }
                        .id("Empty")
                    }
                    .onReceive(vm.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)){
                            scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                        }
                        
                    }
                    
                    
                    
                }
                
                
            
                        
                    
               
            }
            .safeAreaInset(edge: .bottom){
                HStack {
                    Button{
                        showImagePicker.toggle()
                    }
                label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 30))
                        .foregroundColor(Color("LighterGreen"))
                }
                    
                    TextField("Type something", text: $vm.messageText)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(Color.black)
                        .cornerRadius(10)
                        .onSubmit {
                            vm.sendMessage()
                                                       
                        }
                    
                    if monitor.isConnected{
                        
                        
                        
                        Button {
                     
                            vm.sendMessage()
                            
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(Color("LighterGreen"))
                        }
                        .font(.system(size: 26))
                        .padding(.horizontal, 10)
                        .disabled(vm.isMessageTextEmpty)
                        .opacity(vm.isMessageTextEmpty ? 0.5 : 1.0)
                    } else {
                        
                        
                        Button {
                            
                            vm.saveMessagesCache()
                     
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(Color("LighterGreen"))
                        }
                        .font(.system(size: 26))
                        .padding(.horizontal, 10)
                        .opacity(vm.isMessageTextEmpty ? 0.5 : 1.0)
                     
                        
                    }
                    
                    
                }
                .padding()
                .background(Color.white)
            }
            .background(Color.gray.opacity(0.08))
            
            
           
           
        }
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil){
            ImagePicker(image: $image)}
        .onChange(of: selectedImage){
            newImage in
            vm.selectedImage = newImage
            vm.sendMessage()
        }
        
        .navigationTitle("Brigadier")
            .navigationBarItems(trailing: Button(action: {
                vm.count += 1
            }, label: {
                
            }))
            .onAppear{vm.loadMessageCache()}
            .onDisappear{ vm.firestoreListener?.remove()}
        
            
            
    }
    
    
}
