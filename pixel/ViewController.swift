//
//  ViewController.swift
//  pixel
//
//  Created by Simon Westerlund on 2017-08-31.
//  Copyright © 2017 Simon Westerlund. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let pixelView = PixelView(frame: view.bounds)
        pixelView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        view.addSubview(pixelView)
        
        pixelView.start()
    }
}

