//
//  ViewController.swift
//  ModelIOVoxelSmash
//
//  Created by Joss Manger on 11/30/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import Cocoa
import SceneKit

class ViewControllerSCN: NSViewController {

    @IBOutlet weak var applyForcesButton: NSButton!
    @IBOutlet weak var button: NSButton!
    var scnRenderer:SceneKitRenderer!
    private var clicks = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        applyForcesButton.isEnabled = false
        scnRenderer = SceneKitRenderer(view: view as! SCNView)
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func applyForce(_ sender: Any) {
        clicks = 2
        button.title = "reset"
        scnRenderer.applyForce()
    }
    @IBAction func buttonAction(_ sender: Any) {
        clicks += 1
        switch clicks {
        case 1:
            button.title = "Apply Physics"
            applyForcesButton.isEnabled = true
        case 2:
            button.title = "Reset"
        default:
            clicks = 0
            applyForcesButton.isEnabled = false
            button.title = "Generate Mesh"
        }
        scnRenderer.initialiseMesh()
    }
   

}

