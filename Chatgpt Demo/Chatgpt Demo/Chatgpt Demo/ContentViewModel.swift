//
//  ContentViewModel.swift
//  Chatgpt Demo
//
//  Created by Saheem Hussain on 04/10/23.
//

import Foundation
import SwiftUI
import OpenAI

struct ChatMessage {
    var chat: Chat
    var createdAt: String
}

class ContentViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var messages = [Chat(role: .system,
                                    content: "Hello!! I am your personal chat assistant. How may I help you?")] //For ui
    @Published var timeArray: [String] = [Date().formatted(date: .omitted, time: .shortened)]
    @Published var wordsArray: [String] = []
    
    @Published var textMssg = ""
    @Published var streamMssg = ""
    
    @Published var isExpand:Bool = false
    @Published var first = true
    @Published var isUserScrolling = false
    @Published var responseStatus: Bool? //nil: app launched, true: response is loading on screen and false: response finished loading
    @Published var apiLoading: Bool?
    //    @Published var regenerateClicked = false
    @Published var stopClicked = false
    
    @Published var wholeSize: CGSize = .zero
    @Published var scrollViewSize: CGSize = .zero
    @Published var atEnd: Bool = true
    
    let openAI = OpenAI(apiToken: <#your_api_key#>)
    var storageMessages: [Chat] = [] //For api
    
    //MARK: - Inititalizer
    init() {
        storageMessages = messages
        apiLoading = nil
        responseStatus = nil
    }
    
    //MARK: - Methods
    func addobservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardApperence), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardApperence(notification: NSNotification) {
        
        isExpand = true
    }
    
    @objc func keyboardDisappear(notification: NSNotification) {
        
        isExpand = false
    }
    
    func hideKeyboard() {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
    }
    
    func isAtEnd(offset: CGPoint) {
        
        print(scrollViewSize.height, wholeSize.height)
        
        if (-1 * offset.y) >= scrollViewSize.height - wholeSize.height {
            isUserScrolling = false
            atEnd = true
            print("User has reached the bottom of the ScrollView.")
        } else {
            print("not reached.")
            atEnd = false
        }
    }
    
    func sendMessage() {
        
        if !textMssg.isEmpty {
            isUserScrolling = false
            //regenerateClicked = false
            stopClicked = false
            first = true
            
            storageMessages.append(Chat(role: .user, content: textMssg))
            messages.append(Chat(role: .user, content: textMssg))
            timeArray.append(Date().formatted(date: .omitted, time: .shortened))
            
            chat()
            textMssg = String()
        }
    }
    
    //if api is loading or response is being loaded on screen then disable sending new messages
    func disablesendMessage() -> Bool {
        
        if let apiLoading, let responseStatus {
            
            if !apiLoading && !responseStatus {
                return false
            } else {
                return true
            }
            
        } else {
            return false
        }
    }
    
    func stopgenerating() {
        //regenerateClicked = false
        stopClicked = true
        responseStatus = false
    }
    
    func regenerateResponse() {
        
        //regenerateClicked = true
        isUserScrolling = false
        stopClicked = false
        first = true
        
        storageMessages.append(storageMessages[storageMessages.count - 2])
        
        chat()
    }
    
    //api call
    func chat() {
        
        // Because the models have no memory of past requests, all relevant information must be supplied as part of the conversation history in each request. If a conversation cannot fit within the model’s token limit, it will need to be shortened in some way(such as keep the summarized conversation in request)
        
        // To mimic the effect seen in ChatGPT where the text is returned iteratively, set the stream parameter to true.
        
        let query = ChatQuery(model: .gpt3_5Turbo,
                              messages: storageMessages,
                              temperature: 0,
                              topP: 1,
                              stop: ["\\n"],
                              presencePenalty: 0,
                              frequencyPenalty: 0,
                              stream: true) //false if not stream
        
        apiLoading = true
        responseStatus = false
        
        // chats(query: query)
        chatStream(query: query)
    }
    
    // if you want to show full response at once
    func chats(query: ChatQuery) {
        
        openAI.chats(query: query) { result in
            //Handle result here
            self.apiLoading = false
            switch result {
            case .success(let result):
                
                self.messages.append(Chat(role: result.choices[0].message.role, content: result.choices[0].message.content))
                self.timeArray.append(Date().formatted(date: .omitted, time: .shortened))
                self.storageMessages.append(Chat(role: .assistant, content: self.wordsArray.joined()))
                
                print(result)
                self.textMssg = String()
                
            case .failure(let error):
                print(error)
                self.textMssg = String()
            }
        }
    }
    
    //if you want to shpw response word by word as chatgpt shows
    func chatStream(query: ChatQuery) {
        
        openAI.chatsStream(query: query) { result in
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let result):
                    
                    if let content = result.choices[0].delta.content {
                        
                        if self.first {
                            self.wordsArray = []
                            self.first = false
                        }
                        self.wordsArray.append(content)
                    }
                    
                    print(result)
                    self.textMssg = String()
                    
                case .failure(let error):
                    print(error)
                    self.wordsArray = []
                    self.textMssg = String()
                }
            }
            
        } completion: { error in
            
            if let error {
                print(error)
                self.apiLoading = nil
            } else {
                
                DispatchQueue.main.async {
 
                    if !self.wordsArray.isEmpty {
                        self.apiLoading = false
                        // if self.regenerateClicked {
                        //     self.messages[self.messages.count - 1] = Chat(role: .assistant, content: self.wordsArray.joined())
                        //     self.timeArray[self.timeArray.count - 1] = Date().formatted(date: .omitted, time: .shortened)
                        // } else {
                        self.messages.append(Chat(role: .assistant, content: self.wordsArray.joined()))
                        self.timeArray.append(Date().formatted(date: .omitted, time: .shortened))
                        //}
                        self.storageMessages.append(Chat(role: .assistant, content: self.wordsArray.joined()))
                        
                        self.typeWriter()
                    } else {
                        self.apiLoading = nil
                    }
                }
            }
        }
    }
    
    //effect to show word one by one
    func typeWriter(at position: Int = 0) {
        
        if !stopClicked {
            self.responseStatus = true
            if position == 0 {
                streamMssg = String()
            }
            if position < wordsArray.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.streamMssg.append(self.wordsArray[position])
                    self.typeWriter(at: position + 1)
                }
            } else {
                self.responseStatus = false
                //regenerateClicked = false
                stopClicked = false
            }
        } else {
            self.messages[self.messages.count - 1] = Chat(role: .assistant, content: self.streamMssg)
            self.responseStatus = false
        }
    }
}
