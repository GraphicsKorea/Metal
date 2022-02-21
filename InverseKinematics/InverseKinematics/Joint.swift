//
//  Joint.swift
//  InverseKinematics
//
//  Created by Danny Jang on 2022/02/19.
//

import MetalKit

class Joint {
    let sphere: Sphere
    let cube: Cube
    var rotation: SIMD3<Float>
    var length: Float
    var buffer = MeshBuffer()
    var parent: Joint?
    
    var model: float4x4 {
        var matrix = float4x4(rotation: rotation / 180.0 * Float.pi)
        if parent != nil {
            matrix = parent!.model * float4x4(translation: [0, parent!.length, 0]) * matrix
        }
        return matrix
    }
    
    var jointPosition: SIMD3<Float> {
        let position = model * SIMD4<Float>(0, 0, 0, 1)
        return [position.x, position.y, position.z]
    }
    
    var endPosition: SIMD3<Float> {
        let position = model * SIMD4<Float>(0, length, 0, 1)
        return [position.x, position.y, position.z]
    }
    
    var rotationX: SIMD3<Float> {
        let axis = model * SIMD4<Float>(1, 0, 0, 0)
        return [axis.x, axis.y, axis.z]
    }
    
    var rotationY: SIMD3<Float> {
        let axis = model * SIMD4<Float>(0, 1, 0, 0)
        return [axis.x, axis.y, axis.z]
    }
    
    var rotationZ: SIMD3<Float> {
        let axis = model * SIMD4<Float>(0, 0, 1, 0)
        return [axis.x, axis.y, axis.z]
    }
    
    init(chain: Chain, rotation: SIMD3<Float>, length: Float, color: SIMD3<Float>) {
        sphere = chain.sphere
        cube = chain.cube
        self.rotation = rotation
        self.length = length
        buffer.color = color
    }
    
    func jacobianX(target: SIMD3<Float>) -> SIMD3<Float> {
        let axis = simd_normalize(rotationX)
        let diff = simd_normalize(target - jointPosition)
        return simd_cross(axis, diff)
    }
    
    func jacobianY(target: SIMD3<Float>) -> SIMD3<Float> {
        let axis = simd_normalize(rotationY)
        let diff = simd_normalize(target - jointPosition)
        return simd_cross(axis, diff)
    }
    
    func jacobianZ(target: SIMD3<Float>) -> SIMD3<Float> {
        let axis = simd_normalize(rotationZ)
        let diff = simd_normalize(target - jointPosition)
        return simd_cross(axis, diff)
    }
    
    func update(target: SIMD3<Float>, deltaPosition: SIMD3<Float>) {
        let dr = deltaPosition * 0.1
        // jacobianN는 이미 역행렬입니다.
        let dx = simd_dot(jacobianX(target: target), dr)
        let dy = simd_dot(jacobianY(target: target), dr)
        let dz = simd_dot(jacobianZ(target: target), dr)
        let dt = simd_normalize(SIMD3<Float>(dx, dy, dz))
        rotation += dt
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        buffer.model = model
        encoder.setVertexBytes(&buffer, length: MemoryLayout<MeshBuffer>.size, index: 2)
        encoder.setFragmentBytes(&buffer, length: MemoryLayout<MeshBuffer>.size, index: 2)
        sphere.draw(encoder)
        
        buffer.model = model * float4x4(scale: [1, length, 1]) * float4x4(translation: [0, 0.5, 0])
        encoder.setVertexBytes(&buffer, length: MemoryLayout<MeshBuffer>.size, index: 2)
        encoder.setFragmentBytes(&buffer, length: MemoryLayout<MeshBuffer>.size, index: 2)
        cube.draw(encoder)
    }
}
