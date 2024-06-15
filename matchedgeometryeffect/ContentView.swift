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
    
    @State private var showingImage: Image? = nil
    
    var gridView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] ){
            ForEach(urls, id: \.self) { url in
                Color.clear
                    .aspectRatio(contentMode: .fit)
                    .overlay {
                        AsyncImage(url: url, content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .onTapGesture {
                                    if showingImage == nil {
                                        showingImage = image
                                    }
                                }
                        }, placeholder: {  ProgressView() })
                    }
                    .clipped()
            }
        }
    }

    var body: some View {
        ScrollView {
            gridView
                .padding()
        }
        .overlay {
            if let image = showingImage {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    Color.clear
                        .overlay {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                }
                .onTapGesture {
                    showingImage = nil
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
