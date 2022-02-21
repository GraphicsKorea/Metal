//
//  Geometry.swift
//  Common
//
//  Created by Danny Jang on 2022/02/19.
//

import ModelIO
import MetalKit

protocol Mesh {
    var vertexDescriptor: MTLVertexDescriptor? { get }
    
    func draw(_ encoder: MTLRenderCommandEncoder)
}

class Sphere {
    var radius: Float
    var mesh: MTKMesh

    init(renderer: Renderer, radius: Float = 0.5, segments: UInt32 = 16) {
        let rawMesh = MDLMesh(sphereWithExtent: vector_float3(repeating: radius),
                              segments: vector_uint2(repeating: segments),
                              inwardNormals: false,
                              geometryType: .triangles,
                              allocator: renderer.bufferAllocator)

        do {
            self.radius = radius
            self.mesh = try MTKMesh(mesh: rawMesh, device: renderer.device)
        } catch {
            fatalError("Fail to initialize Sphere.")
        }
    }
}

extension Sphere: Mesh {
    var vertexDescriptor: MTLVertexDescriptor? {
        return MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
    }

    func draw(_ encoder: MTLRenderCommandEncoder) {
        for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
            encoder.setVertexBuffer(vertexBuffer.buffer,
                                    offset: vertexBuffer.offset,
                                    index: index)
        }
        for submesh in mesh.submeshes {
            encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                          indexCount: submesh.indexCount,
                                          indexType: submesh.indexType,
                                          indexBuffer: submesh.indexBuffer.buffer,
                                          indexBufferOffset: submesh.indexBuffer.offset)
        }
    }
}

class Cube {
    var mesh: MTKMesh
    
    init(renderer: Renderer) {
        let rawMesh = MDLMesh(boxWithExtent: [1, 1, 1], segments: [1, 1, 1], inwardNormals: false, geometryType: .triangles, allocator: renderer.bufferAllocator)
        
        do {
            mesh = try MTKMesh(mesh: rawMesh, device: renderer.device)
        } catch {
            fatalError("Fail to initialize Cube.")
        }
    }
}

extension Cube: Mesh {
    var vertexDescriptor: MTLVertexDescriptor? {
        return MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
    }

    func draw(_ encoder: MTLRenderCommandEncoder) {
        for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
            encoder.setVertexBuffer(vertexBuffer.buffer,
                                    offset: vertexBuffer.offset,
                                    index: index)
        }
        for submesh in mesh.submeshes {
            encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                          indexCount: submesh.indexCount,
                                          indexType: submesh.indexType,
                                          indexBuffer: submesh.indexBuffer.buffer,
                                          indexBufferOffset: submesh.indexBuffer.offset)
        }
    }
}
