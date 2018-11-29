//
//  TransformShaders.metal
//  Matrices
//
//  Created by Joss Manger on 11/29/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float point_size [[ point_size ]];
};

struct Constants{
    float animateBy;
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]], constant Constants &constants [[ buffer(1) ]], constant float4x4 &matrix [[ buffer(2) ]] ) {
    
    VertexOut vertex_out;
    vertex_out.position = vertex_in.position;
    
    vertex_out.position = matrix * float4(vertex_out.position);
    
    vertex_out.position.x += constants.animateBy;
    
    vertex_out.point_size = 5.0;
    
    return vertex_out;
}

fragment float4 fragment_main(constant float4 &color [[buffer(0)]]) {
    return color;
}
