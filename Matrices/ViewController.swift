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
    
    
    @IBOutlet weak var button: NSButton!
    var triangles:Int = 0 {
        didSet{
            renderer.setTriangles(drawTriangles: triangles)
        }
    }
    
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

    @IBAction func drawTriangles(_ sender: Any) {
        if(sender is NSSegmentedControl){
            let button = (sender as! NSSegmentedControl)
            triangles = button.selectedSegment
        }
    }
    
}

