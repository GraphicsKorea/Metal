//
//  Camera.swift
//  Common
//
//  Created by Danny Jang on 2022/02/20.
//

import simd
import Metal

class Camera {
    var view: float4x4
    var projection: float4x4
    var buffer = CameraBuffer()
    
    init(from: SIMD3<Float>, to: SIMD3<Float>, up: SIMD3<Float>, fov: Float, aspect: Float) {
        view = float4x4(from:from, to:to, up: up)
        projection = float4x4(fov: fov, near: 0.001, far: 1000.0, aspect: aspect)
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        buffer.view = view
        buffer.projection = projection
        encoder.setVertexBytes(&buffer, length: MemoryLayout<CameraBuffer>.size, index: 1)
    }
}
