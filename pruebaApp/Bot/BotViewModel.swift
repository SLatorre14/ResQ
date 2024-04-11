//
//  BotViewModel.swift
//  pruebaApp
//
//  Created by IMAC on 11/04/24.
//

import SwiftUI
import ChatGPTSwift
@MainActor
class BotViewModel: ObservableObject{
    let api = ChatGPTAPI(apiKey: "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")
    @Published var message = ""
    @Published var chatMessages = [ChatMessageBot]()
    @Published var isWaitingForResponse = false
    
    func sendMessage() async throws{
        let userMessage = ChatMessageBot(message)
        chatMessages.append(userMessage)
        message = ""
        isWaitingForResponse = true
        
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
