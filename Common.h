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
} Uniforms;

typedef struct {
    float animateBy;
} Constants;

#endif /* Common_h */
