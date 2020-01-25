//
//  BaseShader.metal
//  MetalFromTheStartAgain
//
//  Created by Joss Manger on 1/19/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float4 position [[ attribute(0) ]];
};

struct VertexOut {
  float4 position [[ position ]];
  float4 color;
};


constant float4 red = {1,0,0,1};
constant float4 green = {0,1,0,1};
constant float4 blue = {0,0,1,1};

constant float4 colors[] = {red,green,blue};

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]], constant int *colorIndex [[ buffer(1) ]], uint id [[vertex_id]]) {
  VertexOut out;

  out.position = vector_float4(vertex_in.position.xyz,1.0);
  out.color = colors[*colorIndex];//colors[*offset];
  
  if (id == 878){
    out.color = float4(1,0,1,1);
  }

  return out;
}

fragment float4 fragment_main(const VertexOut v_in [[ stage_in ]]) {
  return v_in.color;
}
