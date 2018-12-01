//
//  ViewController.swift
//  ModelIOVoxelSmash
//
//  Created by Joss Manger on 11/30/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import Cocoa
import SceneKit

class ViewController: NSViewController {

    var scnRenderer:SceneKitRenderer!
    private var clicks = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnRenderer = SceneKitRenderer(view: view as! SCNView)
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func mouseDown(with event: NSEvent) {
        clicks += 1
        print("mouse click",clicks)
        scnRenderer.initialiseMesh()
    }

}

