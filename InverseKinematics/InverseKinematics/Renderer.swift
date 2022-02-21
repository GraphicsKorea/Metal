//
//  MetalViewDelegate.swift
//  Common
//
//  Created by Danny Jang on 2022/02/18.
//

import SwiftUI
import MetalKit

class Renderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var bufferAllocator: MTKMeshBufferAllocator?
    var camera: Camera!
    var chain: Chain!
    var target: Target!
    
    override init() {
        // 메탈을 사용하기 위해 필요한 자원을 초기화 합니다.
        guard let device: MTLDevice = MTLCreateSystemDefaultDevice(),
              let commandQueue: MTLCommandQueue = device.makeCommandQueue()
        else {
            fatalError("Fail to initialize Metal.")
        }
        
        self.device = device
        self.commandQueue = commandQueue
        super.init()
        
        // Model I/O를 사용하기 위해 필요한 Allocator를 생성합니다.
        self.bufferAllocator = MTKMeshBufferAllocator(device: self.device)
        
        // 데모를 위한 Scene을 구성합니다.
        chain = Chain(renderer: self)
        target = Target(renderer: self)
        
        // Scene의 초기값을 설정합니다.
        target.position = [0, 6, 0]
        chain.target = target.position
    }
    
    func update(view: MTKView) {
        // 체인에 타겟을 설정하고 IK를 계산합니다.
        chain.target = target.position
        chain.update()
    }
    
    func render(view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer()
        else {
            return
        }

        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        guard
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            return
        }

        // 체인과 타겟을 렌더링 합니다.
        encoder.setTriangleFillMode(.lines)
        camera.render(encoder)
        target.render(encoder)
        chain.render(encoder)
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func resize(view: MTKView, width: Float, height: Float) {
        camera = Camera(from: [0, 0, 15], to: [0, 0, 0], up: [0, 1, 0],
                        fov: 45.0, aspect: width / height)
    }
    
    func simulate() {
        // IK의 새로운 타겟을 설정합니다.
        var direction = SIMD2<Float>()
        direction.x = Float.random(in: -1...1)
        direction.y = Float.random(in: -1...1)
        direction = simd_normalize(direction)
        direction *= Float.random(in: 0...6)
        target.position.x = direction.x
        target.position.y = direction.y
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        resize(view: view, width: Float(size.width), height: Float(size.height))
    }

    func draw(in view: MTKView) {
        update(view: view)
        render(view: view)
    }
}
