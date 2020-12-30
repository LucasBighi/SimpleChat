//
//  ChatsViewController.swift
//  SimpleChat
//
//  Created by Lucas Marques Bighi on 26/10/20.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatsViewController: UIViewController {
    @IBOutlet weak var newChatButton: UIBarButtonItem!
    @IBOutlet weak var loginBarButton: UIBarButtonItem!
    @IBOutlet weak var chatsTableView: UITableView!
    
    private var chats: [Chat]?
    private var selectedChat: Chat?

    override func viewDidLoad() {
        super.viewDidLoad()
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let loggedUser = user, let email = loggedUser.email {
                self.loginBarButton.title = "Welcome, \(email)"
                self.getChats(of: loggedUser)
            } else {
                self.loginBarButton.title = "Login"
                self.chats = nil
                self.chatsTableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MessagesViewController {
            vc.chat = selectedChat
        }
    }
    
    private func alert(_ title: String, _ message: String, _ okHandler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
    
    private func getChats(of user: User) {
        let db = Firestore.firestore()
        let chatsRef = db.collection("chats")
            chatsRef.whereField("users", arrayContains: user.email!)
                .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var chats = [Chat]()
                    for chatSnapshot in querySnapshot!.documents {
                        chats.append(Chat(snapshot: chatSnapshot))
                    }
                    self.chats = chats
                    self.chatsTableView.reloadData()
                }
            }
    }
    
    @objc private func newChatAction(_ sender: UIButton) {
        
    }

    @IBAction func loginLogoutAction(_ sender: UIBarButtonItem) {
        if Auth.auth().currentUser == nil {
            var loginAlert = UIAlertController()
            loginAlert = alert("Login", "Enter User and Password to Login") { (action) in
                if let textFields = loginAlert.textFields {
                    let email = textFields[0].text ?? ""
                    let password = textFields[1].text ?? ""
                    
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            self.present(self.alert("Error logging", error.localizedDescription, nil), animated: true)
                        }
                    }
                }
            }
            loginAlert.addTextField { (textField) in
                textField.placeholder = "Email"
                textField.keyboardType = .emailAddress
            }
            loginAlert.addTextField { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
            present(loginAlert, animated: true)
        } else {
            present(alert("Logout", "Are you sure to want to logout?") { (action) in
                do {
                    try Auth.auth().signOut()
                } catch let error {
                    self.present(self.alert("Error logging", error.localizedDescription, nil), animated: true)
                }
            }, animated: true)
        }
    }
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let chats = chats, chats.count != 0 {
            tableView.restore()
        } else {
            if Auth.auth().currentUser == nil {
                tableView.setEmptyMessage("Please make login to see your chats")
            } else {
                tableView.setEmptyMessage("Start a new chat clicking\non the + button")
            }
        }
        return chats?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ChatsTableViewCell,
           let chat = chats?[indexPath.row] {
            cell.setup(with: chat)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "messages") as? MessagesViewController {
            vc.chat = chats?[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
