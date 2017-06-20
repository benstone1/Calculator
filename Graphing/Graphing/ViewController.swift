//
//  ViewController.swift
//  Graphing
//
//  Created by C4Q  on 6/19/17.
//  Copyright © 2017 C4Q . All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var graphingView: GraphingView! {
        didSet {
            let handler = #selector(graphingView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphingView, action: handler)
            graphingView.addGestureRecognizer(pinchRecognizer)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

