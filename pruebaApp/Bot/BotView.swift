//
//  BotView.swift
//  pruebaApp
//
//  Created by IMAC on 11/04/24.
//

import SwiftUI

struct BotView: View {
    
    @StateObject private var viewModel = BotViewModel()
    @ObservedObject var monitor = NetworkMonitor()
        
    var body: some View {
            VStack{
                
                if monitor.isConnected{
                    ScrollViewReader{ proxy in
                        ScrollView{
                            LazyVStack(spacing: 16){
                                ForEach(viewModel.chatMessages){ message in
                                    messageView(message)
                                }
                                Color.clear
                                    .frame(height: 1)
                                    .id("bottom")
                                
                            }
                        }
                        .onReceive(viewModel.$chatMessages.throttle(for: 0.5, scheduler: RunLoop.main, latest: true)){ chatMessages in
                            guard !chatMessages.isEmpty else { return }
                            withAnimation{
                                proxy.scrollTo("bottom")
                            }
                        }
                    }
                    HStack{
                        TextField("Message ...", text: $viewModel.message, axis:.vertical)
                            .textFieldStyle(.roundedBorder)
                            .foregroundStyle(Color.black)
                        if viewModel.isWaitingForResponse{
                            ProgressView()
                                .padding()
                        } else {
                            Button {
                                
                                sendMessage()
                                
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(Color("LighterGreen"))
                            }
                            .font(.system(size: 26))
                            .padding(.horizontal, 10)
                        }
                        
                        
                    }
                    .padding()
                }
                else{
                        Text("No internet Connection")
                            .foregroundColor(.green)
                            .font(.title)
                            .padding(.top, 20)
                }
            }
            
            
        }
    
    func messageView(_ message: ChatMessageBot) -> some View{
        HStack{
            if message.owner == .user{
                Spacer(minLength: 60)
            }
            if !message.text.isEmpty{
                VStack{
                    Text(message.text)
                        .foregroundColor(message.owner == .user ? .black : .white)
                        .padding(12)
                        
                        .background(message.owner == .user ? Color("LightGreen") : .gray.opacity(0.1))
                        .cornerRadius(16)
                        .overlay(
                            alignment: message.owner == .user ? .topTrailing : .topLeading
                        ) {
                            Text(message.owner.rawValue.capitalized)
                                .foregroundColor(.gray)
                                .font(.caption)
                                .offset(y: -16)
                        }
                        
                }
            }
        }
    }
    
    func sendMessage(){
        Task {
            do{
                try await viewModel.sendMessage()
            } catch{
                print(error.localizedDescription)
            }
        }
    }
    
    
}

struct BotView_Previews: PreviewProvider {
    static var previews: some View {
        BotView()
    }
}
