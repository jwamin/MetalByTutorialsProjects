//
//  Shaders.metal
//  MetalTemplate
//
//  Created by Joss Manger on 11/28/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

struct Constants{
    float animateBy;
};

vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]], constant Constants &constants [[ buffer(1) ]] ) {
    float4 position = vertex_in.position;
    position.x += constants.animateBy;
    return position;
}

fragment float4 fragment_main() {
    return float4(0, 0, 1, 1);
}
