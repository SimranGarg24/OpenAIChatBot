//
//  CreateImageViewModel.swift
//  Chatgpt Demo
//
//  Created by Saheem Hussain on 06/10/23.
//

import SwiftUI
import OpenAI

final class CreateImageViewModel: ObservableObject {
    
    let openAI = OpenAIManager.shared
    
    @Published var imageurl: String?
    @Published var isImageLoading: Bool?
    @Published var text = ""
    @Published var error: String?
    @Published var isPresented: Bool = false
    
    func generateImage(prompt: String) {
        
        let query = ImagesQuery(prompt: prompt, n: 1, size: "512x512")
        
        self.isImageLoading = true
        error = nil
        isPresented = false
        openAI.images(query: query) { result, error in
            
            DispatchQueue.main.async {
                if let result {
                    self.imageurl = result.data[0].url
                } else if let error {
                    self.imageurl = nil
                    self.isPresented = true
                    self.error = error.localizedDescription
                }
                
                self.isImageLoading = false
            }
        }
    }
}
