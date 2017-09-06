//
//  View.swift
//  pixel
//
//  Created by Simon Westerlund on 2017-08-31.
//  Copyright © 2017 Simon Westerlund. All rights reserved.
//

import Cocoa
import ScreenSaver

class View: ScreenSaverView {
    var pixelView: PixelView!
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        pixelView = PixelView(frame: bounds)
        pixelView.easingSpeed = isPreview ? 6 : 3
        pixelView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        addSubview(pixelView)
        
        
        animationTimeInterval = 1 / 60.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func startAnimation() {
        super.startAnimation()
        pixelView.start()
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        needsDisplay = true
    }
    
    override func hasConfigureSheet() -> Bool {
        return false
    }
    
    override func configureSheet() -> NSWindow? {
        return nil
    }
}
