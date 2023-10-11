//
//  TabItem.swift
//  Chatgpt Demo
//
//  Created by Saheem Hussain on 10/10/23.
//

import SwiftUI

struct TabItem: View {
    var body: some View {
        TabView {
           ContentView()
                .tabItem {
                    Label("Chat", systemImage: "ellipsis.message")
                }
            
            CreateImage()
                 .tabItem {
                     Label("Images", systemImage: "pencil.tip")
                 }
        }
    }
}

struct TabItem_Previews: PreviewProvider {
    static var previews: some View {
        TabItem()
    }
}
