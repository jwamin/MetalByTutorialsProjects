//
//  Renderer.m
//  HelloTriangle
//
//  Created by Joss Manger on 1/25/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

#import "Renderer.h"
@import simd;
@import MetalKit;


@implementation Renderer
{
    id<MTLDevice> _device;

    // The render pipeline generated from the vertex and fragment shaders in the .metal shader file.
    id<MTLRenderPipelineState> _pipelineState;

    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> _commandQueue;

    // The current size of the view, used as an input to the vertex shader.
    vector_uint2 _viewportSize;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device andView:(MTKView*)view
{
  self = [super init];
  if (self) {
    self.device = device;
    self.view = view;
    
    [self mtkView:_view drawableSizeWillChange:_view.drawableSize];
    
    view.delegate = self;
    NSError *error = NULL;
    
    // Load all the shader files with a .metal file extension in the project.
    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];

    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragment_main"];
    
    MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
    [descriptor setVertexFunction:vertexFunction];
    [descriptor setFragmentFunction:fragmentFunction];
    descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    descriptor.label = @"Simple Pipeline";
    
    _pipelineState = [device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    
    _commandQueue = [_device newCommandQueue];
    
  }
  return self;
}

- (void) tellMeAboutMyDevice
{
  NSLog(@"my device is %@, and my view is: %@", [self.device name], _view);
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
  
  _viewportSize.x = size.width;
  _viewportSize.y = size.height;
  NSLog(@"updating %2f %2f", size.width,size.height);
  
}

- (void)drawInMTKView:(MTKView *)view{
  
  static const VertexIn triangleVertices[] =
  {
      // 2D positions,    RGBA colors
      { {  250,  -250 }, { 1, 0, 0, 1 } },
      { { -250,  -250 }, { 0, 1, 0, 1 } },
      { {    0,   250 }, { 0, 0, 1, 1 } },
  };
  
  id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
  
  commandBuffer.label = @"my command buffer";
 
  MTLRenderPipelineDescriptor *descriptor = view.currentRenderPassDescriptor;
  
  id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
  
  encoder.label = @"my renderencoder";
  
  [encoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, 0.0, 1.0}];
  
  [encoder setRenderPipelineState:_pipelineState];
  
  [encoder setVertexBytes:&triangleVertices length:sizeof(triangleVertices) atIndex:0];
  [encoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:1];
  
  [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
  
  [encoder endEncoding];
  
  [commandBuffer presentDrawable:view.currentDrawable];
  
  [commandBuffer commit];
  
}

@end
