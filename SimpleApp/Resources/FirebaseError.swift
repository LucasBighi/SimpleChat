//
//  FirebaseError.swift
//  SimpleApp
//
//  Created by Lucas Marques Bighi on 14/08/20.
//  Copyright © 2020 Lucas Marques Bighi. All rights reserved.
//

import Foundation

enum FirebaseError: Error {
    case noUser
    case unknown
    
    init(_ error: Error) {
        switch error.localizedDescription {
        case "There is no user record corresponding to this identifier. The user may have been deleted.":
            self = FirebaseError.noUser
        default:
            self = FirebaseError.unknown
        }
    }
}
