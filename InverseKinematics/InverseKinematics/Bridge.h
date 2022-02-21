//
//  Bridege.h
//  InverseKinematics
//
//  Created by Danny Jang on 2022/02/20.
//

#ifndef Bridge_h
#define Bridge_h

#include <simd/simd.h>

typedef struct {
    matrix_float4x4 model;
    vector_float3 color;
} MeshBuffer;

typedef struct {
    matrix_float4x4 view;
    matrix_float4x4 projection;
} CameraBuffer;

#endif /* Bridge_h */
