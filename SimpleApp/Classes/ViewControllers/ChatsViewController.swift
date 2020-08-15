//
//  ChatsViewController.swift
//  SimpleApp
//
//  Created by Lucas Marques Bighi on 03/05/20.
//  Copyright © 2020 Lucas Marques Bighi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChatsViewController: UIViewController {

    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    @IBOutlet weak var chatsTableView: UITableView!
    
    private let chatsViewModel = ChatsViewModel()
    private let userViewModel = UserViewModel()
    private let messagesViewModel = MessagesViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUser()
        chatsTableView.rx.setDelegate(self).disposed(by: disposeBag)
        bindChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        bindChats()
    }
    
    private func bindUser() {
        userViewModel.currentUser.bind { (user) in
            if let user = user {
                self.barButtonItem.title = "Welcome, \(user.email!)"
            } else {
                self.barButtonItem.title = "Login"
            }
        }.disposed(by: disposeBag)
    }
    
    private func bindChats() {
        chatsViewModel.chats.bind(to: chatsTableView.rx.items(cellIdentifier: "cell", cellType: ChatTableViewCell.self)) { row, chat, cell in
            cell.setup(with: chat)
        }.disposed(by: disposeBag)
        
        chatsTableView.rx.itemSelected.subscribe(onNext: { (indexPath) in
            let user = ChatUser(self.chatsViewModel.chats.value[indexPath.row].sender)
            self.messagesViewModel.getMessages(of: user)
            }).disposed(by: disposeBag)
        
        chatsViewModel.getChats()
    }
    
    private func logout() {
        present(alert(title: "Logout", message: "Are you sure want to logout?")
            .addAction(title: "Yes, please logout me") { (alert, action) in
                self.userViewModel.logout { (error) in
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        .addAction(title: "No, I'm mistaken", handler: nil), animated: true)
    }
    
    private func login() {
        present(alert(title: "Login to your account", message: "Input your e-mail and password below")
            .addTextField { (textField) in
            textField.placeholder = "E-mail"
            textField.keyboardType = .emailAddress
        }
        .addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        .addAction(title: "Login", handler: { (alert, action) in
            print("Alert superclass: \(alert.superclass)")
            let email = alert.textFields![0].text!
            let password = alert.textFields![1].text!
            self.userViewModel.login(email: email, password: password) { (result) in
                switch result {
                case .failure(let error):
                    if error == .noUser {
                        self.showNewUserPrompt(email: email, password: password)
                    }
                case .success(_):
                    break
                }
            }
        })
        .addAction(title: "Cancel", handler: nil), animated: true)
    }
    
    func showNewUserPrompt(email: String, password: String) {
        present(alert(title: "Error loging", message: "There is no user registered with email \(email). Do you like to create it?")
            .addAction(title: "Yes, I want") { (alert, action) in
                self.userViewModel.createUser(email: email, password: password) { (result) in
                    switch result {
                    case .success(_):
                        self.showAlert(title: "Success", message: "The user with email \(email) was succesfully created!")
                    case .failure(let error):
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
        }
        .addAction(title: "", handler: nil), animated: true)
    }

    @IBAction func barButtonAction(_ sender: UIBarButtonItem) {
        if userViewModel.currentUser.value != nil {
            logout()
        } else {
             login()
         }
    }
}

extension ChatsViewController: UITableViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
}
