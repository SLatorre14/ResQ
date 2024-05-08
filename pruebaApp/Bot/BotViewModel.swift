//
//  BotViewModel.swift
//  pruebaApp
//
//  Created by IMAC on 11/04/24.
//

import SwiftUI
import ChatGPTSwift
import FirebaseFirestore

@MainActor
class BotViewModel: ObservableObject{
    let api = ChatGPTAPI(apiKey: "")
    @Published var message = ""
    @Published var chatMessages = [ChatMessageBot]()
    @Published var isWaitingForResponse = false
    
    func sendMessage() async throws{
        let userMessage = ChatMessageBot(message)
        chatMessages.append(userMessage)
        message = ""
        isWaitingForResponse = true
        
        let ref = FirebaseManager.shared.firestore.collection("messagesBot").document()
        let data = ["timeStamp": Timestamp()] as [String : Any]
        ref.setData(data){error in
            if let error = error{
                print(error)
                return
            }

        }
        
        let assistantMessage = ChatMessageBot(owner: .assistant, "")
        chatMessages.append(assistantMessage)
        let stream = try await api.sendMessageStream(text: message)
        for try await line in stream {
            if let lastMessage = chatMessages.last {
                let text = lastMessage.text
                let newMessage = ChatMessageBot(owner: .assistant, text + line)
                chatMessages[chatMessages.count - 1] = newMessage
            }
        }
    }
}
