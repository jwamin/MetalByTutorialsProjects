//
//  AppDelegate.swift
//  MetalArithmetic
//
//  Created by Joss Manger on 1/20/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!

  var computer:GPUComputer!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    
    guard let device = MTLCreateSystemDefaultDevice() else {
      fatalError()
    }
    
    computer = GPUComputer(device: device)
    
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }


}

class GPUComputer {
  
  var device:MTLDevice
  var computePipelineState: MTLComputePipelineState!
  
  init(device:MTLDevice) {
    self.device = device
    
    let commandQueue = device.makeCommandQueue()
    let metalLibrary = device.makeDefaultLibrary()
    let kFunction = metalLibrary?.makeFunction(name: "k_main_addition")!
    
    computePipelineState = try! device.makeComputePipelineState(function: kFunction!)
    
    var commandBuffer = commandQueue?.makeCommandBuffer()
    
    let encoder = commandBuffer?.makeComputeCommandEncoder()
    
    encoder?.setComputePipelineState(computePipelineState)
    
    var lhs: UnsafeRawPointer = Float(4).pointer
    
    encoder?.setBytes(lhs, length: MemoryLayout<Float>.stride, index: 0)
    
    var rhs: UnsafeRawPointer = Float(6).pointer
    
    encoder?.setBytes(rhs, length: MemoryLayout<Float>.stride, index: 1)

    var outBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: .storageModeShared)!
    
    encoder?.setBuffer(outBuffer, offset: 0, index: 2)
    
    encoder?.dispatchThreads(MTLSizeMake(1, 1, 1), threadsPerThreadgroup: MTLSizeMake(1, 1, 1))
    
    encoder?.endEncoding()
    commandBuffer?.addCompletedHandler({ (buffer) in
      print(buffer.status == .completed)
      let contents = outBuffer.contents()
      let fl = contents.bindMemory(to: Float.self, capacity: 1)
      print(fl.pointee)
    })
    commandBuffer?.commit()
    commandBuffer?.waitUntilCompleted()


    
  }
  
  
}


extension Float {
  var pointer: UnsafeRawPointer {
    let mutable = UnsafeMutablePointer<Float>.allocate(capacity: 1)
    mutable.initialize(to: self)
    return UnsafeRawPointer(mutable)
  }
  
  var mutablePointer: UnsafeMutableRawPointer {
    let mutable = UnsafeMutablePointer<Float>.allocate(capacity: 1)
    mutable.initialize(to: self)
    return UnsafeMutableRawPointer(mutable)
  }
  
}
