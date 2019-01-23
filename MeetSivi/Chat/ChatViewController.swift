//
//  ChatViewController.swift
//  MeetSivi
//
//  Created by Norayr Harutyunyan on 1/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Alamofire

class ChatViewController: MSGMessengerViewController {

    let you = User(displayName: "You", avatar: nil, avatarUrl: nil, isSender: true)
    
    let server = User(displayName: "Server", avatar: nil, avatarUrl: nil, isSender: false)
    
    var initialID = 0
    var id:Int {
        self.initialID  = self.initialID + 1
        return self.initialID
    }
    
    var userId:Int?
    var waitingForAnswer = false
    
    var command:String?
    
//    var messages:String?
    
    override var style: MSGMessengerStyle {
        var style = MessengerKit.Styles.iMessage
        style.headerHeight = 10
        style.footerHeight = 10
//        style.inputPlaceholder = "Message"
//        style.alwaysDisplayTails = true
//        style.outgoingBubbleColor = .magenta
//        style.outgoingTextColor = .black
//        style.incomingBubbleColor = .green
//        style.incomingTextColor = .yellow
//        style.backgroundColor = .orange
//        style.inputViewBackgroundColor = .purple
        return style
    }
    
    
    lazy var messages: [[MSGMessage]] = {
        return []
//            [
//                MSGMessage(id: 1, body: .emoji("🐙💦🔫"), user: tim, sentAt: Date()),
//            ],
//            [
//                MSGMessage(id: 2, body: .text("Yeah sure, gimme 5"), user: steve, sentAt: Date()),
//                MSGMessage(id: 3, body: .text("Okay ready when you are"), user: steve, sentAt: Date())
//            ],
//            [
//                MSGMessage(id: 4, body: .text("Awesome 😁"), user: tim, sentAt: Date()),
//            ],
//            [
//                MSGMessage(id: 5, body: .text("Ugh, gotta sit through these two…"), user: steve, sentAt: Date()),
//            ],
//            [
//                MSGMessage(id: 6, body: .text("Every. Single. Time."), user: tim, sentAt: Date()),
//            ],
//            [
//                MSGMessage(id: 7, body: .emoji("🙄😭"), user: steve, sentAt: Date())
//            ]
//        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Chat"
        
        dataSource = self
        delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "language"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(menuButtonTapped(sender:)))

        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil) { (notification) in
//            self.messages.append([MSGMessage(id: 8, body: .text("All right."), user: self.server, sentAt: Date())])
//
//            var sectionIndex = self.messages.count - 1
//            self.collectionView.insertSections([sectionIndex])
//
//            self.messages.append([MSGMessage(id: 9, body: .text("Not now."), user: self.server, sentAt: Date())])
//            sectionIndex = self.messages.count - 1
//            self.collectionView.insertSections([sectionIndex])
        }
        
//        self.messages.append([MSGMessage(id: self.id, body: .text("....."), user: self.tim, sentAt: Date())])
//        
//        let sectionIndex = self.messages.count - 1
//        self.collectionView.insertSections([sectionIndex])

        Alamofire.request(Urls.addUser(),
                          method: .post,
                          parameters: ["command":"ADD_USER"],
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { response in

//                            self.removeLastMessage()

                            switch response.result {
                            case .success:
                                print(response)
                                
                                if let responseData = response.result.value as? NSDictionary {
                                    print(responseData)
                                    
                                    guard let command_ = responseData["command"] as? String,
                                        let userId_ = responseData["userId"] as? Int,
                                        let messages_ = responseData["messages"] as? Array<String> else {
                                            return
                                    }
                                    
                                    if let messageText = messages_.first {
                                        self.command = command_
                                        self.waitingForAnswer = true
                                        self.userId = userId_
                                        
                                        self.messages.append([MSGMessage(id: self.id, body: .text(messageText), user: self.server, sentAt: Date())])
                                        
                                        let sectionIndex = self.messages.count - 1
                                        self.collectionView.insertSections([sectionIndex])
                                    }
                                }

                                break
                            case .failure(let error):
                                
                                print(error)
                            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.scrollToBottom(animated: false)
    }
    
    override func inputViewPrimaryActionTriggered(inputView: MSGInputView) {
        let body: MSGMessageBody = (inputView.message.containsOnlyEmoji && inputView.message.count < 5) ? .emoji(inputView.message) : .text(inputView.message)
        
        let message = MSGMessage(id: self.id, body: body, user: you, sentAt: Date())
        insert(message)
        collectionView.scrollToBottom(animated: false)

        if self.waitingForAnswer, let command = self.command, let userId = self.userId {
            self.messages.append([MSGMessage(id: self.id, body: .text("....."), user: self.server, sentAt: Date())])
            
            let sectionIndex = self.messages.count - 1
            self.collectionView.insertSections([sectionIndex])
            collectionView.scrollToBottom(animated: false)

            Alamofire.request(Urls.addUser(),
                              method: .post,
                              parameters: ["command":command, "value":inputView.message],
                              encoding: JSONEncoding.default,
                              headers: ["userId" : "\(userId)"]).responseJSON { response in
                                
                                self.removeLastMessage()
                                self.collectionView.scrollToBottom(animated: false)

                                switch response.result {
                                case .success:
                                    print(response)
                                    
                                    if let responseData = response.result.value as? NSDictionary {
                                        print(responseData)
                                        
                                        guard let command_ = responseData["command"] as? String,
                                            let messagesList = responseData["messages"] as? Array<String> else {
                                                return
                                        }
                                        
                                        self.command = command_
                                        
                                        if self.command != "INVALID_COMMAND" && self.command != "DONE" {
                                            self.waitingForAnswer = true
                                        } else {
                                            self.waitingForAnswer = false
                                        }
                                        
                                        for message in messagesList {
                                            self.messages.append([MSGMessage(id: self.id, body: .text(message), user: self.server, sentAt: Date())])
                                            
                                            let sectionIndex = self.messages.count - 1
                                            self.collectionView.insertSections([sectionIndex])
                                        }
                                    }
                                    
                                    break
                                case .failure(let error):
                                    self.messages.append([MSGMessage(id: self.id, body: .text("Wrong answer"), user: self.server, sentAt: Date())])
                                    
                                    let sectionIndex = self.messages.count - 1
                                    self.collectionView.insertSections([sectionIndex])

                                    print(error)
                                }
            }
        }
    }
    
    override func insert(_ message: MSGMessage) {
        
        collectionView.performBatchUpdates({
            if let lastSection = self.messages.last, let lastMessage = lastSection.last, lastMessage.user.displayName == message.user.displayName {
                self.messages[self.messages.count - 1].append(message)
                
                let sectionIndex = self.messages.count - 1
                let itemIndex = self.messages[sectionIndex].count - 1
                self.collectionView.insertItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])
                
            } else {
                self.messages.append([message])
                let sectionIndex = self.messages.count - 1
                self.collectionView.insertSections([sectionIndex])
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: true)
            self.collectionView.layoutTypingLabelIfNeeded()
        })
        
    }
    
    override func insert(_ messages: [MSGMessage], callback: (() -> Void)? = nil) {
        
        collectionView.performBatchUpdates({
            for message in messages {
                if let lastSection = self.messages.last, let lastMessage = lastSection.last, lastMessage.user.displayName == message.user.displayName {
                    self.messages[self.messages.count - 1].append(message)
                    
                    let sectionIndex = self.messages.count - 1
                    let itemIndex = self.messages[sectionIndex].count - 1
                    self.collectionView.insertItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])
                    
                } else {
                    self.messages.append([message])
                    let sectionIndex = self.messages.count - 1
                    self.collectionView.insertSections([sectionIndex])
                }
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: false)
            self.collectionView.layoutTypingLabelIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                callback?()
            }
        })
        
    }

    func removeLastMessage() {
        let sectionIndex = self.messages.count - 1
        self.messages.removeLast()
        self.collectionView.deleteSections(IndexSet(arrayLiteral: self.messages.count))
    }
    
    @objc func menuButtonTapped(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Languages", message: "Please Select an language", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "English", style: .default , handler:{ (UIAlertAction)in
            print("English")
        }))
        
        alert.addAction(UIAlertAction(title: "Finnish", style: .default , handler:{ (UIAlertAction)in
            print("Finnish")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }

}

// MARK: - Overrides

extension ChatViewController {
    
}

// MARK: - MSGDataSource

extension ChatViewController: MSGDataSource {
    
    func numberOfSections() -> Int {
        return messages.count
    }
    
    func numberOfMessages(in section: Int) -> Int {
        return messages[section].count
    }
    
    func message(for indexPath: IndexPath) -> MSGMessage {
        return messages[indexPath.section][indexPath.item]
    }
    
    func footerTitle(for section: Int) -> String? {
//        return "Just now"
        return ""
    }
    
    func headerTitle(for section: Int) -> String? {
        return messages[section].first?.user.displayName
    }

}

// MARK: - MSGDelegate

extension ChatViewController: MSGDelegate {
    
    func linkTapped(url: URL) {
        print("Link tapped:", url)
    }
    
    func avatarTapped(for user: MSGUser) {
        print("Avatar tapped:", user)
    }
    
    func tapReceived(for message: MSGMessage) {
        print("Tapped: ", message)
        
//        let sectionIndex = self.messages.count - 1
//        let itemIndex = self.messages[sectionIndex].count - 1
//
//        self.messages[self.messages.count - 1].removeLast()
//        self.messages[self.messages.count - 1].removeLast()
//
//        self.collectionView.deleteItems(at: [IndexPath(item: itemIndex - 1, section: sectionIndex), IndexPath(item: itemIndex, section: sectionIndex)])
    }
    
    func longPressReceieved(for message: MSGMessage) {
        print("Long press:", message)
    }
    
    func shouldDisplaySafari(for url: URL) -> Bool {
        return true
    }
    
    func shouldOpen(url: URL) -> Bool {
        return true
    }
    
}
