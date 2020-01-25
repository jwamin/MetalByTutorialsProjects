//
//  AppDelegate.swift
//  MetalFromTheStartAgain
//
//  Created by Joss Manger on 1/19/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import Cocoa
import MetalKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var metalKitView: MyMTKView!
  var renderer: Renderer!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    
    guard  let metalDevice = MTLCreateSystemDefaultDevice() else {
      fatalError("mo metal")
    }
    
    metalKitView.device = metalDevice
    
    renderer = Renderer(metalKitView: metalKitView)
    metalKitView.delegate = renderer
    
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
    metalKitView.isPaused = true
  }


}

class Renderer : NSObject, MTKViewDelegate {
  
  var mesh:MTKMesh!
  let metalkitView:MyMTKView!
  var commandQueue:MTLCommandQueue!
  var pipelineState:MTLRenderPipelineState!
  var library:MTLLibrary!
  var device: MTLDevice{
    return metalkitView.device!
  }
  
  typealias BasicMetalFunctions = (vertex:MTLFunction,fragment:MTLFunction)
  
  var basic:BasicMetalFunctions!
  
  init(metalKitView:MyMTKView) {
    
    self.metalkitView = metalKitView
  
    super.init()
    metalKitView.clearColor = MTLClearColorMake(0, 0, 0, 1)
    self.metalkitView.isPaused = true
    initialiseMesh()
    initialiseGPUPipeline()
    
    metalKitView.isPaused = false
  }
  
  private func initialiseMesh(){
    //allocator manages memeory for mesh data
    let allocator = MTKMeshBufferAllocator(device: device)
    
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .float3
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0
    vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
    
    let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
    
    (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
    
    guard let url = Bundle.main.url(forResource: "choo-choo", withExtension: "obj") else {
      fatalError("no silly file")
    }
    
    let mdlMesh = MDLAsset(url: url,vertexDescriptor: meshDescriptor, bufferAllocator: allocator).object(at: 0) as! MDLMesh
    //reference to metalkit mesh
    mesh = try! MTKMesh(mesh: mdlMesh, device: device)
    
  }
  
  private func initialiseGPUPipeline(){
    
     commandQueue = device.makeCommandQueue()
     library = device.makeDefaultLibrary()
     
    let vertex = library.makeFunction(name: "vertex_main")!
    let fragment = library.makeFunction(name: "fragment_main")!
    
    basic = (vertex:vertex,fragment:fragment)
    
    let descriptor = MTLRenderPipelineDescriptor()
    descriptor.colorAttachments[0].pixelFormat = metalkitView.colorPixelFormat
    descriptor.vertexFunction = vertex
    descriptor.fragmentFunction = fragment
    
    descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
    
    pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
    
  }
  
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    let ratio = size.width / size.height
    print("new size: \(size), ratio:\(ratio)")
  }
  
  var color:SIMD4<Float> = [1,0,1,1];
  var firstPass = true
  func draw(in view: MTKView) {
    
    guard let commandBuffer = commandQueue.makeCommandBuffer(), let descriptor = view.currentRenderPassDescriptor, let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
      fatalError("no metal worky")
    }
    
    renderEncoder.setRenderPipelineState(pipelineState)
    
    renderEncoder.setVertexBuffer(mesh!.vertexBuffers[0].buffer, offset: 0, index: 0)
    
    
    //renderEncoder.setFragmentBytes(&color, length: MemoryLayout<SIMD4<Float>>.size, index: 0)
    //ensure submeshes exits
    
    var index = 0
    
    for submesh in mesh.submeshes{
      
      let ptr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
       ptr.initialize(to: index)
       
       renderEncoder.setVertexBytes(ptr, length: MemoryLayout<Int>.size, index: 1)
       
       index += 1
       if index > 2 {
         index = 0
       }
      
      renderEncoder.drawIndexedPrimitives(type: (metalkitView.renderingMode) ? .triangle : .line, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)

 
      
    }
    
    firstPass = false
    
    renderEncoder.endEncoding()
    
    guard let drawable = view.currentDrawable else {
      fatalError()
    }
    
    commandBuffer.present(drawable)
    
    commandBuffer.commit()
    
  }
  
  
}

class MyMTKView : MTKView {
  
  var renderingMode:Bool = false {
    didSet{
      print("rendering mode now \(renderingMode)")
    }
  }
  
  override var device: MTLDevice? {
    didSet {
       print("looks like we got a device \(device)")
    }
  }
  
  override init(frame frameRect: CGRect, device: MTLDevice?) {
    super.init(frame: frameRect, device: device)
    print("hello", device, frameRect)
  }
  
  override func mouseUp(with event: NSEvent) {
    
    renderingMode = !renderingMode
    
  }
  
  required init(coder: NSCoder) {
    super.init(coder: coder)
    
  }
}
