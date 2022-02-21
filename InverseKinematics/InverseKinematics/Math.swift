//
//  Math.swift
//  Common
//
//  Created by Danny Jang on 2022/02/19.
//

import simd

extension float4x4 {
    static func identity() -> float4x4 {
        return matrix_identity_float4x4
    }

    init(translation: SIMD3<Float>) {
        let matrix = float4x4(
            [            1,             0,             0, 0],
            [            0,             1,             0, 0],
            [            0,             0,             1, 0],
            [translation.x, translation.y, translation.z, 1]
        )
        self = matrix
    }
  
    init(scale: SIMD3<Float>) {
        let matrix = float4x4(
            [scale.x,       0,       0, 0],
            [      0, scale.y,       0, 0],
            [      0,       0, scale.z, 0],
            [      0,       0,       0, 1]
        )
        self = matrix
    }
  

    init(rotationX angle: Float) {
        let matrix = float4x4(
            [1,          0,           0, 0],
            [0, cos(angle), -sin(angle), 0],
            [0, sin(angle),  cos(angle), 0],
            [0,          0,           0, 1]
        )
        self = matrix
    }
  
    init(rotationY angle: Float) {
        let matrix = float4x4(
            [ cos(angle), 0, sin(angle), 0],
            [          0, 1,          0, 0],
            [-sin(angle), 0, cos(angle), 0],
            [          0, 0,          0, 1]
        )
        self = matrix
    }
    
    init(rotationZ angle: Float) {
        let matrix = float4x4(
            [cos(angle), -sin(angle), 0, 0],
            [sin(angle),  cos(angle), 0, 0],
            [         0,           0, 1, 0],
            [         0,           0, 0, 1]
        )
        self = matrix
    }
  
    init(rotation angle: SIMD3<Float>) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationX * rotationY * rotationZ
    }
    
    init(fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = lhs ? far / (far - near) : far / (near - far)
        let X = SIMD4<Float>(x, 0, 0, 0)
        let Y = SIMD4<Float>(0, y, 0, 0)
        let Z = lhs ? SIMD4<Float>(0, 0, z, 1) : SIMD4<Float>(0, 0, z, -1)
        let W = lhs ? SIMD4<Float>(0, 0, z * -near, 0) : SIMD4<Float>(0, 0, z * near, 0)
        self.init()
        columns = (X, Y, Z, W)
    }
  
    init(from: SIMD3<Float>, to: SIMD3<Float>, up: SIMD3<Float>) {
        let z = normalize(to - from)
        let x = normalize(cross(up, z))
        let y = cross(z, x)
        let X = SIMD4<Float>(x.x, y.x, z.x, 0)
        let Y = SIMD4<Float>(x.y, y.y, z.y, 0)
        let Z = SIMD4<Float>(x.z, y.z, z.z, 0)
        let W = SIMD4<Float>(-dot(x, from), -dot(y, from), -dot(z, from), 1)
        self.init()
        columns = (X, Y, Z, W)
    }
    
    init(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) {
        let X = SIMD4<Float>(2 / (right - left), 0, 0, 0)
        let Y = SIMD4<Float>(0, 2 / (top - bottom), 0, 0)
        let Z = SIMD4<Float>(0, 0, 1 / (far - near), 0)
        let W = SIMD4<Float>((left + right) / (left - right),
                             (top + bottom) / (bottom - top),
                             near / (near - far),
                             1)
        self.init()
        columns = (X, Y, Z, W)
    }

    var upperLeft: float3x3 {
        let x = SIMD3<Float>(columns.0.x, columns.0.y, columns.0.z)
        let y = SIMD3<Float>(columns.1.x, columns.1.y, columns.1.z)
        let z = SIMD3<Float>(columns.2.x, columns.2.y, columns.2.z)
        return float3x3(columns: (x, y, z))
    }
}
