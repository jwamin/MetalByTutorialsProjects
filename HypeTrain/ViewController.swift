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
    
    let panSlowFactor:CGFloat = 20
    let slowFactor:CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metalView = view as? MTKView else {
            fatalError("yeah no metalview")
        }
        
        renderer = Renderer(metalView: metalView)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(gesture(_:)))
        metalView.addGestureRecognizer(pinch)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(gesture(_:)))
        metalView.addGestureRecognizer(pan)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @objc func gesture(_ sender:UIGestureRecognizer) -> Void {
        if(sender is UIPanGestureRecognizer){
            let pan = (sender as! UIPanGestureRecognizer)
            let velocity = pan.velocity(in: view)
            renderer.rotationDegs -= Float(velocity.x / panSlowFactor)
            renderer.yRotationDegs += Float(velocity.y / panSlowFactor)
        } else if sender is UIPinchGestureRecognizer{
            let pinch = sender as! UIPinchGestureRecognizer
            let point = pinch.velocity / slowFactor
            renderer.zScale += Float(point)
        }
    }

}

