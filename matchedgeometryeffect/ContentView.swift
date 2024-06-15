//
//  ContentView.swift
//  matchedgeometryeffect
//
//  Created by Cydiater on 6/6/2024.
//

import SwiftUI

let numImages = 128

let urls : [URL] = {
    let dims = [200, 300, 400, 500, 600, 700]
    var urls: [URL] = []
    for idx in 0..<numImages {
        let width = dims.randomElement()!
        let height = dims.randomElement()!
        let urlString = "https://picsum.photos/id/\(idx)/\(width)/\(height)"
        let url = URL(string: urlString)!
        urls.append(url)
    }
    return urls
}()

struct ContentView: View {
    @Namespace private var namespace
    
    let animation = Animation.easeInOut(duration: 0.2)
    
    @State private var imageSelected: Image? = nil
    @State private var imageUrlSelected: URL? = nil
    @State private var presentingImage = false
    
    var gridView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] ){
            ForEach(urls, id: \.self) { url in
                Color.clear
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(id: imageUrlSelected == url ? "base" : url.absoluteString, in: namespace, isSource: true)
                    .overlay {
                        AsyncImage(url: url, content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .onChange(of: imageUrlSelected) {
                                    if imageUrlSelected == url {
                                        imageSelected = image
                                        withAnimation(animation) {
                                            presentingImage = true
                                        }
                                    }
                                }
                        }) {
                            ProgressView()
                        }
                    }
                    .clipped()
                    .opacity(imageUrlSelected == url ? 0 : 1)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if imageUrlSelected == nil {
                            imageUrlSelected = url
                        }
                    }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            gridView
                .padding()
        }
        .overlay {
            ZStack {
                Color.clear
                    .matchedGeometryEffect(id: "enlarged", in: namespace, isSource: true)
                
                if let image = imageSelected {
                    Color.black
                        .ignoresSafeArea()
                        .opacity(presentingImage ? 1 : 0)
                    
                    Color.clear
                        .overlay {
                            image
                                .resizable()
                                .aspectRatio(contentMode: presentingImage ? .fit : .fill)
                        }
                        .clipped()
                        .matchedGeometryEffect(id: presentingImage ? "enlarged" : "base", in: namespace, isSource: false)
                        .allowsHitTesting(presentingImage)
                        .onTapGesture {
                            if presentingImage {
                                withAnimation(animation) {
                                    presentingImage = false
                                } completion: {
                                    imageSelected = nil
                                    imageUrlSelected = nil
                                }
                            }
                        }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
