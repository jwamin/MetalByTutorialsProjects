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
    
    //divisors to slow the movement from gesture recognisers
    let panSlowFactor:CGFloat = 20
    let slowFactor:CGFloat = 10
    
    //render triangles?
    var triangles:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metalView = view as? MTKView else {
            fatalError("yeah no metalview")
        }
        
        renderer = Renderer(metalView: metalView)
        // Do any additional setup after loading the view, typically from a nib.
        
        //Create and add gesture recognisers
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(gesture(_:)))
        metalView.addGestureRecognizer(pinch)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(gesture(_:)))
        metalView.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(gesture(_:)))
        metalView.addGestureRecognizer(tap)
        
    }

    @objc func gesture(_ sender:UIGestureRecognizer) -> Void {
        
        //function responds to multiple gesture recognisers, switch to determine which code to run
        switch sender {
        case _ where sender is UITapGestureRecognizer:
            triangles = !triangles
            renderer.setTriangles(drawTriangles: triangles)
        case _ where sender is UIPanGestureRecognizer:
            let pan = (sender as! UIPanGestureRecognizer)
            let velocity = pan.velocity(in: view)
            renderer.rotationDegs -= Float(velocity.x / panSlowFactor)
            renderer.yRotationDegs += Float(velocity.y / panSlowFactor)
        case _ where sender is UIPinchGestureRecognizer:
            let pinch = sender as! UIPinchGestureRecognizer
            let point = pinch.velocity / slowFactor
            renderer.zScale += Float(point)
        default:
            break
        }
        
    }

}

