//
//  WithZoomableDetailViewOverlay.swift
//  matchedgeometryeffect
//
//  Created by Cydiater on 15/6/2024.
//

import SwiftUI

class ZoomableImageViewModel: ObservableObject {
    @Published var imageSelected: Image? = nil
    @Published var imageUrlSelected: URL? = nil
    @Published var presentingImage = false
    
    let namespace: Namespace.ID
    
    init(namespace: Namespace.ID) {
        self.namespace = namespace
    }
}

struct ZoomableSquareAsyncImage: View {
    let url: URL
    
    @ObservedObject var vm: ZoomableImageViewModel
    
    let animation = Animation.easeInOut(duration: 0.2)
    
    var body: some View {
        Color.clear
            .aspectRatio(contentMode: .fit)
            .matchedGeometryEffect(id: vm.imageUrlSelected == url ? "base" : url.absoluteString, in: vm.namespace, isSource: true)
            .overlay {
                AsyncImage(url: url, content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .onChange(of: vm.imageUrlSelected) {
                            if vm.imageUrlSelected == url {
                                vm.imageSelected = image
                                withAnimation(animation) {
                                    vm.presentingImage = true
                                }
                            }
                        }
                }) {
                    ProgressView()
                }
            }
            .clipped()
            .opacity(vm.imageUrlSelected == url ? 0 : 1)
            .contentShape(Rectangle())
            .onTapGesture {
                if vm.imageUrlSelected == nil {
                    vm.imageUrlSelected = url
                }
            }
    }
}

struct WithZoomableDetailViewOverlay<Content: View>: View {
    let content: (ZoomableImageViewModel) -> Content
    @ObservedObject var vm: ZoomableImageViewModel
    
    @State private var offset = CGSize.zero
    let animation = Animation.easeInOut(duration: 0.2)
    
    var distance: Double { sqrt(offset.width * offset.width + offset.height * offset.height) }

    var detailViewBackgroundOpacity: Double {
        if vm.presentingImage {
            let maximumDistance: Double = 200
            return max(0, maximumDistance - distance) / maximumDistance
        } else {
            return 0
        }
    }
    
    var detailViewScaleEffect: Double {
        if vm.presentingImage {
            let maximumDistance: Double = 1000
            return max(max(0, maximumDistance - distance) / maximumDistance, 0.8)
        } else {
            return 1
        }
    }
    
    func dismissDetailView() {
        if vm.presentingImage {
            withAnimation(animation) {
                vm.presentingImage = false
                offset = CGSize.zero
            } completion: {
                vm.imageSelected = nil
                vm.imageUrlSelected = nil
            }
        }
    }
    
    init(namespace: Namespace.ID, content: @escaping (ZoomableImageViewModel) -> Content) {
        self.content = content
        self.vm = ZoomableImageViewModel(namespace: namespace)
    }
    
    var body: some View {
        content(vm)
            .overlay {
                ZStack {
                    Color.clear
                        .matchedGeometryEffect(id: "enlarged", in: vm.namespace, isSource: true)
                    
                    if let image = vm.imageSelected {
                        ZStack {
                            Color.black
                                .ignoresSafeArea()
                                .opacity(detailViewBackgroundOpacity)
                            
                            Color.clear
                                .overlay {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: vm.presentingImage ? .fit : .fill)
                                }
                                .offset(offset)
                                .scaleEffect(detailViewScaleEffect)
                                .clipped()
                                .matchedGeometryEffect(id: vm.presentingImage ? "enlarged" : "base", in: vm.namespace, isSource: false)
                                .allowsHitTesting(vm.presentingImage)
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if vm.presentingImage {
                                        offset = value.translation
                                    }
                                }
                                .onEnded { _ in
                                    if vm.presentingImage {
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

struct UsingWithZoomableDetailViewOverlay: View {
    @Namespace var namespace
    
    var body: some View {
        WithZoomableDetailViewOverlay(namespace: namespace) { vm in
            ScrollView {
                Text("Hello")
                HStack {
                    ZoomableSquareAsyncImage(url: urls[0], vm: vm)
                    ZoomableSquareAsyncImage(url: urls[1], vm: vm)
                    ZoomableSquareAsyncImage(url: urls[2], vm: vm)
                }
                .padding()
                Text("This is a long text...")
            }
        }
    }
}

#Preview {
    UsingWithZoomableDetailViewOverlay()
}
