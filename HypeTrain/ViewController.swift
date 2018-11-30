//
//  ViewController.swift
//  HypeTrain
//
//  Created by Joss Manger on 11/30/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    var renderer:Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metalView = view as? MTKView else {
            fatalError("yeah no metalview")
        }
        
        renderer = Renderer(metalView: metalView)
        
        // Do any additional setup after loading the view, typically from a nib.
    }


}

