//
//  ThreeDViewer.swift
//  Image Gallery
//
//  Created by zihao on 2023/7/16.
//

import SwiftUI
import SceneKit
//import SceneKit.ModelIO

struct ThreeDViewer: UIViewRepresentable {
    var product: String

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()

        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling2X
        view.scene = SCNScene(named: product)
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}
