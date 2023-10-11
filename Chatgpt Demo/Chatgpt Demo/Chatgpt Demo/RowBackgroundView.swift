//
//  RowBackgroundView.swift
//  Chatgpt Demo
//
//  Created by Saheem Hussain on 03/10/23.
//

import SwiftUI
import OpenAI

struct RowBackgroundView: View {
    
    var message: String
    var role: Chat.Role = .system
    var createdAt: String
    
    @State private var width: CGFloat = 0
    @State private var aligment: Alignment = .topLeading
    @State private var offsetx: CGFloat = -12
    @State private var horizontalAlignment: HorizontalAlignment = .leading
    
    var body: some View {
        
        VStack(alignment: horizontalAlignment){
            
            Text(createdAt)
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.bottom, 1)
                
            HStack {
                Text(message)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.teal) // Change to your preferred background color
                    )
            }
            .overlay(
                
                Triangle(rowx: width)
                    .fill(Color.teal) // Match the background color
                    .frame(width: 20, height: 10) // Adjust size as needed
                    .offset(x: offsetx ,y: 0) // Adjust offset to position the pointy end
                , alignment: aligment
            )
        }
        .padding(.horizontal)
        .onAppear {
            if role == .user {
                horizontalAlignment = .trailing
                aligment = .topTrailing
                offsetx = 12
                width = 0
            } else {
                horizontalAlignment = .leading
                aligment = .topLeading
                offsetx = -12
                width = 20
            }
        }
    }
}

struct Triangle: Shape {
    var rowx: CGFloat = 0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rowx, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct RowBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        RowBackgroundView(message: "Hello, how are you?", role: .user, createdAt: "12:50 PM")
    }
}
