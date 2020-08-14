//
//  UIViewControllerExtensions.swift
//  SimpleApp
//
//  Created by Lucas Marques Bighi on 14/08/20.
//  Copyright © 2020 Lucas Marques Bighi. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func alert(title: String, message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
}

extension UIAlertController {
    func addTextField(textField: ((UITextField) -> Void)?) -> UIAlertController {
        let alert = self
        alert.addTextField(configurationHandler: textField)
        return alert
    }
    
    func addAction(title: String, handler: ((UIAlertController, UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = self
        if let handler = handler {
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action) in
                handler(alert, action)
            }))
        } else {
            alert.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        }
        return alert
    }
}
