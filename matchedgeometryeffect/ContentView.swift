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

struct ImagesGridView: View {
    @Namespace private var namespace
    
    let animation = Animation.easeInOut(duration: 0.2)
    
    @State private var imageSelected: Image? = nil
    @State private var imageUrlSelected: URL? = nil
    @State private var presentingImage = false
    
    @State private var offset = CGSize.zero
    
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
    
    var distance: Double { sqrt(offset.width * offset.width + offset.height * offset.height) }

    var detailViewBackgroundOpacity: Double {
        if presentingImage {
            let maximumDistance: Double = 200
            return max(0, maximumDistance - distance) / maximumDistance
        } else {
            return 0
        }
    }
    
    var detailViewScaleEffect: Double {
        if presentingImage {
            let maximumDistance: Double = 1000
            return max(max(0, maximumDistance - distance) / maximumDistance, 0.8)
        } else {
            return 1
        }
    }
    
    func dismissDetailView() {
        if presentingImage {
            withAnimation(animation) {
                presentingImage = false
                offset = CGSize.zero
            } completion: {
                imageSelected = nil
                imageUrlSelected = nil
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
                    ZStack {
                        Color.black
                            .ignoresSafeArea()
                            .opacity(detailViewBackgroundOpacity)
                        
                        Color.clear
                            .overlay {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: presentingImage ? .fit : .fill)
                            }
                            .offset(offset)
                            .scaleEffect(detailViewScaleEffect)
                            .clipped()
                            .matchedGeometryEffect(id: presentingImage ? "enlarged" : "base", in: namespace, isSource: false)
                            .allowsHitTesting(presentingImage)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if presentingImage {
                                    offset = value.translation
                                }
                            }
                            .onEnded { _ in
                                if presentingImage {
                                    if detailViewBackgroundOpacity < 0.8 {
                                        dismissDetailView()
                                    } else {
                                        withAnimation {
                                            offset = CGSize.zero
                                        }
                                    }
                                }
                            }
                    )
                    .onTapGesture {
                        dismissDetailView()
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Images Grid View", destination: ImagesGridView())
                NavigationLink("Using `WithZoomableDetailViewOverlay`", destination: UsingWithZoomableDetailViewOverlay())
            }
            .font(.callout)
        }
    }
}


#Preview {
    ContentView()
}
