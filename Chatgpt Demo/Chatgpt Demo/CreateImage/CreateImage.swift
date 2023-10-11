//
//  CreateImage.swift
//  Chatgpt Demo
//
//  Created by Saheem Hussain on 06/10/23.
//

import SwiftUI

struct CreateImage: View {
    
    @StateObject var viewModel = CreateImageViewModel()

    var body: some View {
        
        NavigationView {
            
            VStack {
                
                if let isImageLoading = viewModel.isImageLoading, !isImageLoading {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(ImageMediums.allCases, id: \.self) { medium in
                                
                                Button {
                                    viewModel.generateImage(prompt: viewModel.text + " \(medium.rawValue)")
                                } label: {
                                    Text(medium.rawValue)
                                        .foregroundColor(.black)
                                        .padding(8)
                                }
                                .background(.gray.opacity(0.4))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                
                ZStack {
                    
                    if let imageUrl = viewModel.imageurl {
                        Spacer()
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 300)
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(2)
                            }
                        }
                        
                    } else {
                        Text("Type promt to generate image!")
                    }
                    
                    VStack {
                        
                        Spacer()
                        if let isImageLoading = viewModel.isImageLoading, isImageLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(2)
                        }
                        Spacer()
                    }
                }
                
                Spacer()
                
                TextField("Type something here...", text: $viewModel.text)
                    .padding()
                
                Button("Generate!") {
                    if !viewModel.text.trimmingCharacters(in: .whitespaces).isEmpty {
                        viewModel.generateImage(prompt: viewModel.text)
                    }
                }
            }
            .navigationTitle("DALL-E")
            .padding()
            .alert(viewModel.error ?? "", isPresented: $viewModel.isPresented) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

struct CreateImage_Previews: PreviewProvider {
    static var previews: some View {
        CreateImage()
    }
}
