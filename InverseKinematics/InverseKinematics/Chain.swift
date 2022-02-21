//
//  Arm.swift
//  InverseKinematics
//
//  Created by Danny Jang on 2022/02/19.
//

import MetalKit

class Chain {
    let sphere: Sphere
    let cube: Cube
    var pipelineState: MTLRenderPipelineState?
    var joints: [Joint] = []
    var target = SIMD3<Float>()
    
    init(renderer: Renderer) {
        sphere = Sphere(renderer: renderer)
        cube = Cube(renderer: renderer)
        
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
        
        joints.append(Joint(chain: self, rotation: [0, 0, 0], length: 2.0, color: [1, 0, 0]))
        joints.append(Joint(chain: self, rotation: [0, 0, 0], length: 2.0, color: [0, 1, 0]))
        joints.append(Joint(chain: self, rotation: [0, 0, 0], length: 2.0, color: [0, 0, 1]))
        
        joints[1].parent = joints[0]
        joints[2].parent = joints[1]
    }
    
    func update() {
        guard let lastJoint = joints.last else {
            return
        }
        
        let deltaPosition: SIMD3<Float> = lastJoint.endPosition - target
        guard simd_length(deltaPosition) >= 0.15 else {
            return
        }
        for joint in joints {
            joint.update(target: target, deltaPosition: deltaPosition)
        }        
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {        
        encoder.setRenderPipelineState(pipelineState!)
        for joint in joints {
            joint.render(encoder: encoder)
        }
    }
}
