//
//  Shaders.metal
//  MetalTemplate
//
//  Created by Joss Manger on 11/28/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

#include <metal_stdlib>
#include "../Common.h"
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float point_size [[ point_size ]];
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]], constant Uniforms &uniforms [[buffer(1)]]) {
    
    VertexOut vertex_out;
    
    // translate vertex position THEN object/model space THEN camera/view space THEN clip space
    vertex_out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertex_in.position;
    
    vertex_out.point_size = 5.0;
    
    return vertex_out;
}

fragment float4 fragment_main(constant float4 &color [[buffer(0)]]) {
    return color;
}
