//
//  OpenAIManager.swift
//  Chatgpt Demo
//
//  Created by Saheem Hussain on 06/10/23.
//

import Foundation
import OpenAI

class OpenAIManager {
    
    let openAI = OpenAI(apiToken: <#your_api_key#>)
    
    static let shared = OpenAIManager()
    private init(){}
    
    func chats(query: ChatQuery, completion: @escaping (ChatResult?, Error?) -> Void) {
        
        openAI.chats(query: query) { result in
            switch result {
            case .success(let result):
                print(result)
                completion(result, nil)
                
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    func chatsStream(query: ChatQuery, onResult: @escaping (ChatStreamResult?, Error?) -> Void, onCompletion: ((Error?) -> Void)?) {
        
        openAI.chatsStream(query: query) { result in
            switch result {
            case .success(let result):
                print(result)
                onResult(result, nil)
                
            case .failure(let error):
                print(error)
                onResult(nil, error)
            }
        } completion: { error in
            if let completion = onCompletion {
                completion(error)
            }
        }
    }
    
    func images(query: ImagesQuery, completion: @escaping (ImagesResult?, Error?) -> Void) {
        
        openAI.images(query: query) { result in
            switch result {
            case .success(let result):
                print(result)
                completion(result, nil)
                
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
}
