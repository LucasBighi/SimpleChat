//
//  StringExtesions.swift
//  SimpleChat
//
//  Created by Lucas Bighi on 16/12/20.
//

import Foundation

extension String {
    
    
    private func time(from date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
