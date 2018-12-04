//
//  Renderer.swift
//  MetalTemplate
//
//  Created by Joss Manger on 11/28/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import MetalKit


class Renderer:NSObject{
    
    static var device:MTLDevice!
    static var commandQueue: MTLCommandQueue!
    
    var mesh:MTKMesh!
    var vertexBuffer:MTLBuffer!
    var pipelineState:MTLRenderPipelineState!
    var depthStencilState:MTLDepthStencilState!
    
    private var drawTriangles:Bool = true
    public var cycle:Bool = false
    
    //animation related instance variables
    var time:Float = 0
    var constants = Constants()
    
    var magenta:float4 = float4(1, 0, 1, 1);
    
    var uniforms = Uniforms()
    
    let projectionFOV:Float = 70
    
    var rotationDegs:Float = 45
    var yRotationDegs:Float = 0
    var zScale:Float = 0
    
    init(metalView:MTKView){
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("no device")
        }
        
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.device = device
        Renderer.device = device
        Renderer.commandQueue = device.makeCommandQueue()!
        
        guard let importmeshFile = Bundle.main.url(forResource: "choo-choo", withExtension: "obj") else {
            fatalError()
        }
        
        
        //Tells the GPU about the layout of streamed data
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 24)
       
        
        
        //buffer allocator
        let allocator = MTKMeshBufferAllocator(device: device)
        
        // Get mesh from file, first, create modelIO asset
        let asset = MDLAsset(url: importmeshFile, vertexDescriptor: vertexDescriptor, bufferAllocator: allocator)
        //cast to modelIO mesh
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        mdlMesh.addNormals(withAttributeNamed: "normals", creaseThreshold: 10.0)
        //cast to metal mesh
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)} catch {
                print("error casting to metal mesh")
        }
        vertexBuffer = mesh.vertexBuffers[0].buffer

        
        
        //Generate pipeline descriptor, there is no need to save access to the library, simply parse the metal shaders and assign the functions to the pipeline Descriptor
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        //Create pipeline descriptor and assign shader functions
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        //Get vertex descriptor from mesh via modelIO
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        //get pixel format from view
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        //compine all into pipeline state which will be used by draw function
        do{
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error{
            print(error.localizedDescription)
        }
        
        //finally, call super
        super.init()
        
        //set background color for GPU draw
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        
        //assign metalkitview delegate to self, which starts the draw loop
        metalView.delegate = self
        print("initialised")
        
        let translation = float4x4(translation: [0, 0.0, zScale])
        let rotation = float4x4(rotation: [0,radians(fromDegrees: self.rotationDegs),0])
        
        uniforms.modelMatrix = translation * rotation
        
        uniforms.viewMatrix = float4x4(translation: [0.5,0,0]).inverse
        
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
        
        buildDepthStencilState()
        
    }
}


extension Renderer:MTKViewDelegate{
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = Float(view.bounds.width) / Float(view.bounds.height)
        
        let projectionMatrix = float4x4(projectionFov: radians(fromDegrees: projectionFOV), near: 0.1, far: 100, aspect: aspect)
        
        uniforms.projectionMatrix = projectionMatrix
    }
    
    
    
    func draw(in view: MTKView) {
        
        guard let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
        }
        renderEncoder.setDepthStencilState(depthStencilState)
        //dodgy but proves a point
        var uniformsInternal = Uniforms()
        
        if(cycle){
            let floatFrames = Float(view.preferredFramesPerSecond);
            
            time += (1 / floatFrames)
            
            switch time {
            case let curr where curr < 2:
                uniformsInternal.modelMatrix = float4x4.identity()
                uniformsInternal.viewMatrix = float4x4.identity()
                uniformsInternal.projectionMatrix = float4x4.identity()
            case let curr where curr < 4:
                uniformsInternal.modelMatrix = uniforms.modelMatrix
                uniformsInternal.viewMatrix = float4x4.identity()
                uniformsInternal.projectionMatrix = float4x4.identity()
            case let curr where curr < 6:
                uniformsInternal.modelMatrix = uniforms.modelMatrix
                uniformsInternal.viewMatrix = uniforms.viewMatrix
                uniformsInternal.projectionMatrix = float4x4.identity()
            case let curr where curr < 10:
                uniformsInternal.modelMatrix = uniforms.modelMatrix
                uniformsInternal.viewMatrix = uniforms.viewMatrix
                uniformsInternal.projectionMatrix = uniforms.projectionMatrix
            default:
                print("eh?")
            }
            
        } else {
            //don't cycle through time, but get mouse input
            let translation = float4x4(translation: [0, 0.0, zScale])
            let rotation = float4x4(rotation: [radians(fromDegrees: self.yRotationDegs),radians(fromDegrees: self.rotationDegs),0])
            
            uniforms.modelMatrix = translation * rotation

            uniformsInternal.modelMatrix = uniforms.modelMatrix
            uniformsInternal.viewMatrix = uniforms.viewMatrix
            uniformsInternal.projectionMatrix = uniforms.projectionMatrix
        }
        
 
        renderEncoder.setRenderPipelineState(pipelineState)
        
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        
        uniforms.viewMatrix = float4x4(translation: [0, 0, -3]).inverse
        
        renderEncoder.setVertexBytes(&uniformsInternal, length: MemoryLayout<Uniforms>.stride, index: 1)
        
        renderEncoder.setFragmentBytes(&magenta, length: MemoryLayout<float4>.stride, index: 0)
        
        for submesh in mesh.submeshes{
            
            renderEncoder.drawIndexedPrimitives(type: ((drawTriangles) ? .triangle : .point), indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
            
        }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        //increment timer
        if(time>=10){
            time = 0
        }
        
    }
}


extension Renderer {
    func setTriangles(drawTriangles:Bool){
        self.drawTriangles = drawTriangles
    }
    
    func buildDepthStencilState(){
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        depthStencilState = Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    
}
