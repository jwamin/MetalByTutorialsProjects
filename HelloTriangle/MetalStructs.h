//
//  MetalStructs.h
//  MetalSandbox
//
//  Created by Joss Manger on 1/25/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

#ifndef MetalStructs_h
#define MetalStructs_h

typedef enum AAPLVertexInputIndex
{
    AAPLVertexInputIndexVertices     = 0,
    AAPLVertexInputIndexViewportSize = 1,
} AAPLVertexInputIndex;

typedef struct {
  float2 position;
  float4 color;
} VertexIn;

//typedef struct {
//  float4 position [[position]];
//  float4 color;
//} VertexOut ;

#endif /* MetalStructs_h */
