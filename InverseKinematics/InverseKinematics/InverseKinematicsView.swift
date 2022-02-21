//
//  MetalView.swift
//  Common
//
//  Created by Danny Jang on 2022/02/17.
//

import SwiftUI
import MetalKit

struct InverseKinematicsView {
    let delegate: MTKViewDelegate
    let device: MTLDevice

    init(renderer: Renderer) {
        delegate = renderer
        device = renderer.device
    }
}

extension InverseKinematicsView: NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView {
        let view: MTKView = MTKView()
        view.delegate = delegate
        view.device = device
        return view
    }
  
    func updateNSView(_ view: MTKView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}

