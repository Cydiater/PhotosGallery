//
//  ContentView.swift
//  matchedgeometryeffect
//
//  Created by Cydiater on 6/6/2024.
//

import SwiftUI

let numImages = 128

class ImagesPresentationManager: ObservableObject {
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
    
    @Published var lastPresentingImage: URL? = nil
    @Published var fullscreenPresentingImage: URL? = nil
    @Published var appearingImages: Set<URL> = []
    
    func imageAppeared(url: URL) {
        appearingImages.insert(url)
    }
    
    func imageDisappeared(url: URL) {
        appearingImages.remove(url)
    }
    
    func present(url: URL?) {
        lastPresentingImage = fullscreenPresentingImage
        fullscreenPresentingImage = url
    }
    
    func isCurrentPresentingImageOrLastPresentingImage(url: URL) -> Bool {
        fullscreenPresentingImage == url || lastPresentingImage == url
    }
}

struct ContentView: View {
    @Namespace private var namespace
    
    @ObservedObject private var imagesManager = ImagesPresentationManager()
            
    let animation = Animation.easeInOut(duration: 0.2)
    
    var gridView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] ){
            ForEach(0..<numImages, id: \.self) { idx in
                let url = imagesManager.urls[idx]
                Color.clear
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(id: url.absoluteString, in: namespace, isSource: true)
                    .onAppear { imagesManager.imageAppeared(url: url) }
                    .onDisappear { imagesManager.imageDisappeared(url: url) }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(animation) {
                            imagesManager.present(url: url)
                        }
                    }
            }
        }
    }
        
    func backgroundOpacityFor(url: URL) -> Double {
        if imagesManager.fullscreenPresentingImage == url {
            return 1.0
        } else {
            return 0.0
        }
    }
    
    @ViewBuilder
    func detailView(url: URL) -> some View {
        Color.black
            .ignoresSafeArea()
            .zIndex(imagesManager.isCurrentPresentingImageOrLastPresentingImage(url: url) ? 1 : 0)
            .opacity(backgroundOpacityFor(url: url))
        
        Color.clear
            .overlay {
                AsyncImage(url: url, content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: (imagesManager.fullscreenPresentingImage == url) ? .fit : .fill)
                }, placeholder: {
                    ProgressView()
                })
            }
            .clipped()
            .zIndex(imagesManager.isCurrentPresentingImageOrLastPresentingImage(url: url) ? 1 : 0)
            .matchedGeometryEffect(id: (imagesManager.fullscreenPresentingImage == url) ? "enlarged" : url.absoluteString, in: namespace, isSource: false)
            .allowsHitTesting(imagesManager.fullscreenPresentingImage == url ? true : false)
            .onTapGesture {
                withAnimation(animation) {
                    imagesManager.present(url: nil)
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
                    .matchedGeometryEffect(id: "enlagred", in: namespace, isSource: true)
                
                ForEach(Array(imagesManager.appearingImages), id: \.absoluteString) { url in
                    detailView(url: url)
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
