//
//  Common.h
//  MetalTemplate
//
//  Created by Joss Manger on 11/29/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef struct {
    float animateBy;
} Constants;

typedef enum {
    unused = 0,
    Sunlight = 1,
    Spotlight = 2,
    Pointlight = 3,
    Ambientlight = 4
} LightType;

typedef struct {
    vector_float3 position;
    vector_float3 color;
    vector_float3 specularColor;
    float intensity;
    vector_float3 attenuation;
    LightType type;
} Light;

typedef struct {
    uint lightCount;
    vector_float3 cameraPosition;
} FragmentUniforms;

#endif /* Common_h */
