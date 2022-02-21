//
//  Target.swift
//  InverseKinematics
//
//  Created by Danny Jang on 2022/02/21.
//

import MetalKit

class Target {
    let sphere: Sphere
    var pipelineState: MTLRenderPipelineState?
    var buffer = MeshBuffer()
    var position: SIMD3<Float> = [0, 0, 0]
    
    init(renderer: Renderer) {
        sphere = Sphere(renderer: renderer)
        
        guard
            let library = renderer.device.makeDefaultLibrary(),
            let vertFunction = library.makeFunction(name: "vertex_main"),
            let fragFunction = library.makeFunction(name: "fragment_main")
        else {
            fatalError("")
        }

        
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDesc.vertexFunction = vertFunction
        pipelineDesc.fragmentFunction = fragFunction
        pipelineDesc.vertexDescriptor = sphere.vertexDescriptor
        pipelineDesc.inputPrimitiveTopology = .triangle
        
        do {
            pipelineState = try renderer.device.makeRenderPipelineState(descriptor: pipelineDesc)
        } catch {
            print(error)
        }
        
        buffer.color = [1, 1, 1]
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(pipelineState!)
        buffer.model = float4x4(translation: position)
        encoder.setVertexBytes(&buffer, length: MemoryLayout<MeshBuffer>.size, index: 2)
        encoder.setFragmentBytes(&buffer, length: MemoryLayout<MeshBuffer>.size, index: 2)
        sphere.draw(encoder)
    }
}
