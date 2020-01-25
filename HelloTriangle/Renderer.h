//
//  Renderer.h
//  HelloTriangle
//
//  Created by Joss Manger on 1/25/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
  vector_float2 position;
  vector_float4 color;
} VertexIn;

@interface Renderer : NSObject<MTKViewDelegate>

- (instancetype)initWithDevice:(id<MTLDevice>)device andView:(MTKView*)view;

@property (retain) id<MTLDevice> device;
@property (retain) MTKView *view;

-(void) tellMeAboutMyDevice;

@end

NS_ASSUME_NONNULL_END
