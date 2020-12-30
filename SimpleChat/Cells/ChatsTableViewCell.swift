//
//  ChatsTableViewCell.swift
//  SimpleChat
//
//  Created by Lucas Marques Bighi on 26/10/20.
//

import UIKit
import FirebaseAuth

class ChatsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatUserLabel: UILabel!
    
    func setup(with chat: Chat) {
        if let currentUser = Auth.auth().currentUser {
            let user = chat.usersEmails.first { $0 != currentUser.email }
            chatUserLabel.text = user
        }
    }
}
