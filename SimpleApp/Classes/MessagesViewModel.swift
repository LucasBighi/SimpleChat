//
//  MessagesViewModel.swift
//  SimpleApp
//
//  Created by Lucas Marques Bighi on 14/08/20.
//  Copyright © 2020 Lucas Marques Bighi. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxCocoa

struct MessagesViewModel {
    let db = Firestore.firestore()
    
    var messages = BehaviorRelay<[Message]>(value: [Message]())
    var ref: DocumentReference? = nil
    
    func getMessages(of user: ChatUser) {
        db.collection("chats").document(user.uid).collection("messages").getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            } else {
                if let documents = snapshot?.documents {
                    for document in snapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                    let messages = documents.compactMap { Message(snapshot: $0) }
                    print(messages)
                    self.messages.accept(messages)
                }
            }
        }
    }
}
