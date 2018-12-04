//
//  Shaders.metal
//  MetalTemplate
//
//  Created by Joss Manger on 11/28/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float3 normal [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 normal;
    float point_size [[ point_size ]];
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]], constant Uniforms &uniforms [[buffer(1)]]) {
    
    VertexOut vertex_out;
    
    // translate vertex position THEN object/model space THEN camera/view space THEN clip space
    vertex_out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertex_in.position;
    vertex_out.normal = vertex_in.normal;
    vertex_out.point_size = 5.0;
    
    return vertex_out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]], constant float4 &color [[buffer(0)]]) {
    float4 sky = float4(0.34, 0.9, 1.0, 1.0);
    float4 earth = float4(0.29, 0.58, 0.2, 1.0);
    float intensity = in.normal.y * 0.5 + 0.5;
    return mix(earth, sky, intensity);
}
