//
//  ChatMessageBot.swift
//  pruebaApp
//
//  Created by IMAC on 11/04/24.
//
import SwiftUI

struct ChatMessageBot: Identifiable{
    var id = UUID().uuidString
    var owner: MessageOwner
    var text: String
    
    init(owner: MessageOwner = .user, _ text: String){

        self.owner = owner
        self.text = text
    }
}
