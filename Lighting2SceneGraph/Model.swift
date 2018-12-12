//
//  File.swift
//  Lighting
//
//  Created by Joss Manger on 12/4/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import MetalKit

class Model : Node{
    
    var vertexBuffer:MTLBuffer!
    var pipelineState:MTLRenderPipelineState!
    let mesh:MTKMesh
    
    init(objName:String,modelExtn:String) {
        
        //buffer allocator
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        
        guard let importmeshFile = Bundle.main.url(forResource: objName, withExtension: modelExtn) else {
            fatalError()
        }
        
        // Get mesh from file, first, create modelIO asset
        let asset = MDLAsset(url: importmeshFile, vertexDescriptor: Model.defaultVertexDescriptor, bufferAllocator: allocator)
        
        //cast to modelIO mesh
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        mdlMesh.addNormals(withAttributeNamed: "normals", creaseThreshold: 10.0)
        
        //cast to metal mesh
        let mesh = try! MTKMesh(mesh: mdlMesh, device: Renderer.device)
        self.mesh = mesh
        vertexBuffer = mesh.vertexBuffers[0].buffer
        
        pipelineState = Model.buildPipelineState(vertexDescriptor: mdlMesh.vertexDescriptor)
        
        super.init()
    }
    
    static var defaultVertexDescriptor: MDLVertexDescriptor = {
        
        //Tells the GPU about the layout of streamed data
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 24)
        
        return vertexDescriptor
        
    }()
    
    private static func buildPipelineState(vertexDescriptor: MDLVertexDescriptor) -> MTLRenderPipelineState {
        let library = Renderer.library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        var pipelineState:MTLRenderPipelineState! // completely working function below omits the force unwrap, no idea how...
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        do{
            pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error{
            print(error.localizedDescription)
        }
        return pipelineState
    }
    
}

//private static func buildPipelineState(vertexDescriptor: MDLVertexDescriptor) -> MTLRenderPipelineState {
//    //Generate pipeline descriptor, there is no need to save access to the library, simply parse the metal shaders and assign the functions to the pipeline Descriptor
//    let library = Renderer.library
//    let vertexFunction = library?.makeFunction(name: "vertex_main")
//    let fragmentFunction = library?.makeFunction(name: "fragment_main")
//
//    var pipelineState: MTLRenderPipelineState
//    //Create pipeline descriptor and assign shader functions
//    let pipelineDescriptor = MTLRenderPipelineDescriptor()
//    pipelineDescriptor.vertexFunction = vertexFunction
//    pipelineDescriptor.fragmentFunction = fragmentFunction
//    //Get vertex descriptor from mesh via modelIO
//    pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
//    //get pixel format from view
//    //compine all into pipeline state which will be used by draw function
//    pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
//    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
//    do {
//        pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//    } catch let error {
//        fatalError(error.localizedDescription)
//    }
//    return pipelineState
//}

