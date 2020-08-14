//
//  ChatsViewModel.swift
//  SimpleApp
//
//  Created by Lucas Marques Bighi on 14/08/20.
//  Copyright © 2020 Lucas Marques Bighi. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxCocoa

struct ChatsViewModel {
    let db = Firestore.firestore()
    
    var chats = BehaviorRelay<[Chat]>(value: [])
    var ref: DocumentReference? = nil
    
    func getChats() {
        db.collection("chats").getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            } else {
                if let documents = snapshot?.documents {
                    for document in snapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                    let chats = documents.compactMap { Chat(snapshot: $0) }
                    self.chats.accept(chats)
                }
            }
        }
    }
}
