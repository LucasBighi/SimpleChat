//
//  Chat.swift
//  SimpleApp
//
//  Created by Lucas Marques Bighi on 14/08/20.
//  Copyright © 2020 Lucas Marques Bighi. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Chat {
    
    let lastMessage: String
    let sender: String
    let time: Date
    
    init?(snapshot: DocumentSnapshot?) {
        guard let dict = snapshot?.data(),
            let lastMessage = dict["lastMessage"] as? String,
            let sender = snapshot?.documentID,
            let time = dict["time"] as? Timestamp else {
                return nil
        }
        
        self.lastMessage = lastMessage
        self.sender = sender
        self.time = time.dateValue()
    }
}
