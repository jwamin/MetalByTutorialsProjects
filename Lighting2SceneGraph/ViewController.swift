//
//  ViewController.swift
//  MetalTemplate
//
//  Created by Joss Manger on 11/28/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    
    var renderer:Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let metalView = view as? MTKView else {
            fatalError("yeah no metalview")
        }
        
        renderer = Renderer(metalView: metalView)
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear() {
        self.view.window?.title = "Metal"
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        print(event.deltaX,event.deltaY)
        renderer.rotationDegs -= Float(event.deltaX)
        renderer.yRotationDegs += Float(event.deltaY)
    }
    
    override func scrollWheel(with event: NSEvent) {
        print(event.scrollingDeltaY)
        renderer.zScale += Float(event.scrollingDeltaY)
    }
    
}

