//
//  Simple.metal
//  HelloTriangle
//
//  Created by Joss Manger on 1/25/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

#include <metal_stdlib>
#include "MetalStructs.h"
using namespace metal;

// Vertex shader outputs and fragment shader inputs
typedef struct
{
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];

    // Since this member does not have a special attribute, the rasterizer
    // interpolates its value with the values of the other triangle vertices
    // and then passes the interpolated value to the fragment shader for each
    // fragment in the triangle.
    float4 color;

} VertexOut;

vertex VertexOut vertex_main(constant VertexIn *vertices_in [[buffer(AAPLVertexInputIndexVertices)]],constant vector_uint2 *viewport [[buffer(AAPLVertexInputIndexViewportSize)]], uint vertex_id [[vertex_id]]){
      VertexOut out;

  // Index into the array of positions to get the current vertex.
  // The positions are specified in pixel dimensions (i.e. a value of 100
  // is 100 pixels from the origin).
  float2 pixelSpacePosition = vertices_in[vertex_id].position.xy;

  // Get the viewport size and cast to float.
  vector_float2 viewportSize = vector_float2(*viewport);
  

  // To convert from positions in pixel space to positions in clip-space,
  //  divide the pixel coordinates by half the size of the viewport.
  out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
  out.position.xy = pixelSpacePosition / (viewportSize / 2.0);

  // Pass the input color directly to the rasterizer.
  out.color = vertices_in[vertex_id].color;

  return out;
}

fragment float4 fragment_main(VertexOut v_out [[stage_in]]){
  return v_out.color;
}
