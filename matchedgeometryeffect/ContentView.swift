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
    @Namespace var namespace
    
    var body: some View {
        WithZoomableDetailViewOverlay(namespace: namespace) { vm in
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] ){
                    ForEach(urls, id: \.self) { url in
                        ZoomableSquareAsyncImage(url: url, vm: vm)
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
