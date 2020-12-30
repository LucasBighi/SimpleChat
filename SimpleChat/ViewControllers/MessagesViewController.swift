//
//  MessagesViewController.swift
//  SimpleChat
//
//  Created by Lucas Marques Bighi on 26/10/20.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    var chat: Chat?
    var messagesData = [[String: Any]]()
    private let db = Firestore.firestore()
    private var messagesRef: CollectionReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.transform = CGAffineTransform(rotationAngle: -.pi)
        if let chat = chat {
            messagesRef = db.collection("chats").document(chat.id).collection("messages")
        }
        getMessages()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    func updateTableContentInset() {
        let numRows = messagesTableView.numberOfRows(inSection: 0)
        var contentInsetTop = messagesTableView.bounds.size.height
        for i in 0..<numRows {
            let rowRect = messagesTableView.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
                break
            }
        }
        messagesTableView.contentInset = UIEdgeInsets(top: contentInsetTop, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func getMessages() {
        messagesRef?.order(by: "time", descending: true).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for messageSnapshot in querySnapshot!.documents {
                    self.messagesData.append([
                        "id": messageSnapshot.documentID,
                        "content": messageSnapshot.get("content") as! String,
                        "sender": messageSnapshot.get("sender") as! String,
                        "time": messageSnapshot.get("time") as! Timestamp
                    ])
                    self.messagesTableView.reloadData()
                }
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.textFieldBottomConstraint.constant = keyboardHeight
            })
        }
        view.layoutIfNeeded()
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.textFieldBottomConstraint.constant = 8
        })
        view.layoutIfNeeded()
    }
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        if let content = messageTextField.text,
           let email = Auth.auth().currentUser?.email {
            let messageData: [String: Any] = [
                "content": content,
                "sender": email,
                "time": Timestamp(date: Date())
            ]
            messagesData.insert(messageData, at: 0)
            messagesTableView.reloadData()
            self.messageTextField.text = nil
            messagesRef?.addDocument(data: messageData, completion: { error in
                if let error = error {
                    print("Error sending message: \(error)")
                }
            })
        }
    }
}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messagesData[indexPath.row]
        if let sender = message["sender"] as? String,
           let currentUser = Auth.auth().currentUser {
            if sender == currentUser.email {
                let cell = tableView.dequeueReusableCell(withIdentifier: "senderCell", for: indexPath) as! MessageSenderTableViewCell
                cell.setup(withMessage: message)
                cell.transform = CGAffineTransform(rotationAngle: .pi)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "receiverCell", for: indexPath) as! MessageReceiverTableViewCell
                cell.setup(withMessage: message)
                cell.transform = CGAffineTransform(rotationAngle: .pi)
                return cell
            }
        }
        return UITableViewCell()
    }
}
