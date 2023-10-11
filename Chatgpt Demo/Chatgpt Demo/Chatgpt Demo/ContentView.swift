//
//  ContentView.swift
//  Chatgpt Demo
//
//  Created by Saheem Hussain on 03/10/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var vm = ContentViewModel()
    
    var body: some View {
        
        VStack {
            
            Text("AI CHATBOT")
                .font(.headline)
            
            ScrollViewReader { proxy in
                ChildSizeReader(size: $vm.wholeSize) {
                    ScrollView {
                        ChildSizeReader(size: $vm.scrollViewSize) {
                            
                            VStack {
                                ForEach(0..<vm.messages.count, id: \.self) { index in
                                    
                                    if vm.messages[index].role == .user {
                                        //shown on right side
                                        HStack {
                                            Spacer()
                                            RowBackgroundView(message: vm.messages[index].content!, role: vm.messages[index].role, createdAt: vm.timeArray[index])
                                        }
                                        .id(index)
                                        .padding(.bottom, 4)
                                    } else {
                                        //shown on left side
                                        HStack {
                                            //last message should be shown one by word
                                            if index != 0 && vm.messages.endIndex - 1 == index {
                                                RowBackgroundView(message: vm.streamMssg, role: vm.messages[index].role, createdAt: vm.timeArray[index])
                                                Spacer()
                                            } else {
                                                RowBackgroundView(message: vm.messages[index].content!, role: vm.messages[index].role, createdAt: vm.timeArray[index])
                                                Spacer()
                                            }
                                        }
                                        .id(index)
                                        .padding(.bottom, 4)
                                    }
                                }
                            }
                            .background(GeometryReader { geometry in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                            })
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                                print(offset)
                                // Check if the user has reached the end of screen, start auto scroll if message is being generated
                                vm.isAtEnd(offset: offset)
                            }
                        }
                    }
                    .padding()
                    .coordinateSpace(name: "scroll")
                    .onChange(of: vm.messages.count) { _ in
                        if !vm.isUserScrolling {
                            //if new message is added(either from user or assistant), reach at end of screen
                            withAnimation {
                                proxy.scrollTo(vm.messages.endIndex - 1, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: vm.streamMssg) { _ in
                        if !vm.isUserScrolling {
                            //autoscroll if message is being generated
                            withAnimation {
                                proxy.scrollTo(vm.messages.endIndex - 1, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: vm.isExpand) { expand in
                        //if keyboard expanded and user is at bottom of screen, scroll view up automatically
                        if expand {
                            if vm.atEnd {
                                withAnimation {
                                    proxy.scrollTo(vm.messages.endIndex - 1, anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        // User started scrolling, set the flag to true
                        vm.isUserScrolling = true
                    }
            )

            Spacer()
            
            VStack {
                
                HStack {
                    Spacer()
                    
                    if let apiLoading = vm.apiLoading, let responseStatus = vm.responseStatus, !apiLoading {
                        
                        if responseStatus {
                            
                            Button {
                                vm.stopgenerating()
                            } label: {
                                Text("Stop generating")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            
                        } else {
                            
                            Button {
                                vm.regenerateResponse()
                            } label: {
                                Text("Regenerate")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                HStack {
                    TextField("Send your message", text: $vm.textMssg, onCommit: {
                        vm.sendMessage()
                    })
                    .padding(8)
                    .border(.gray)
                    .cornerRadius(4)
                    .disabled(vm.disablesendMessage())
                    
                    Button(action: {
                        vm.sendMessage()
                        vm.hideKeyboard()
                    }, label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.teal)
                            .cornerRadius(50)
                    })
                    .padding(.leading)
                    .disabled(vm.disablesendMessage())
                }
            }
            .padding(.horizontal)
            // .background(Color.orange.opacity(0.05))
        }
        .padding(.vertical)
        //.edgesIgnoringSafeArea(.bottom)
        .onTapGesture {
            vm.hideKeyboard()
        }
        .onAppear{
            vm.addobservers()
        }
        
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
