//
//  PixelView.swift
//  pixel
//
//  Created by Simon Westerlund on 2017-08-31.
//  Copyright © 2017 Simon Westerlund. All rights reserved.
//

import Cocoa

final class Step {
    enum Heading: Int {
        case left, up, right, down
    }
    
    let direction: Heading
    var length: CGFloat
    var stepsLeft: CGFloat
    var stepSize: CGFloat = 1
    var smoothingDivider: CGFloat
    
    init(direction: Heading, length: CGFloat, smoothingDivider: CGFloat) {
        self.direction = direction
        self.length = length
        self.stepsLeft = length
        self.smoothingDivider = smoothingDivider
    }
    
    func consumeStep() {
        let divider = self.length / smoothingDivider
        
        if stepsLeft > length / 2 {
            stepSize = max(0.01, (length - stepsLeft) / (length / divider))
        } else {
            stepSize = stepsLeft / (length / divider)
        }
        
        
        stepsLeft -= stepSize
    }
}

extension Step.Heading {
    // type the arrays to make the compiler to compily stuff faster
    var isHorizontal: Bool {
        return [Step.Heading.left, Step.Heading.right].contains(self)
    }
    
    var isVertical: Bool {
        return [Step.Heading.up, Step.Heading.down].contains(self)
    }
}

class PixelView: NSView {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var iterations = 0
    
    // Since the actual screensaver is running on a slower clock speed
    // we need to decrease the number of iterations between each step
    var easingSpeed: CGFloat = 6
    
    var lines: [CGPoint] = []
    var nextDirection: Step! {
        didSet {
            consumeNextStep()
        }
    }
    
    func start() {
        self.iterations = 0
        nextDirection = Step(direction: .left, length: 100, smoothingDivider: easingSpeed)
    }
    
    func consumeNextStep() {
        nextDirection.consumeStep()
        
        switch nextDirection.direction {
        case .left:
            x += nextDirection.stepSize
        case .right:
            x -= nextDirection.stepSize
        case .up:
            y += nextDirection.stepSize
        case .down:
            y -= nextDirection.stepSize
        }
        
        lines.append(CGPoint(x: x, y: y))
        needsDisplay = true
        
        if nextDirection.stepsLeft >= 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: { 
                self.consumeNextStep()
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                if self.iterations == -1 {
                    self.reset()
                    self.start()
                    return
                }
                
                if self.iterations >= 1000 && !self.nextDirection.direction.isHorizontal {
                    self.iterations = -1
                    self.drawLastLine()
                    return
                }
                
                self.iterations += 1
                self.generateAndDrawNextStep()
            })
        }
    }
    
    func reset() {
        x = self.frame.maxX
        y = 0
        
        lines = [CGPoint(x: 0, y: self.y)]
        
        needsDisplay = true
    }
    
    func drawLastLine() {
        nextDirection = Step(direction: .left, length: frame.width * 2, smoothingDivider: easingSpeed)
    }
    
    func generateAndDrawNextStep() {
        var length: CGFloat {
            if arc4random() % 100 == 0 {
                return 300
            } else {
                return CGFloat(arc4random() % 150 + 25)
            }
        }
        nextDirection = Step(direction: randomDirection(except: nextDirection.direction), length: length, smoothingDivider: easingSpeed)
    }
    
    func randomDirection(except: Step.Heading) -> Step.Heading {
        let random = Int(arc4random() % 6)
        
        let direction: Step.Heading
        
        switch random {
        case 0..<3:
            direction = .left
        case 3..<4:
            direction = .right
        case 4..<5:
            direction = .up
        case 5..<6:
            fallthrough
        default:
            direction = .down
        }
        
        if direction.isHorizontal && except.isHorizontal  {
            return randomDirection(except: except)
        }
        
        if direction.isVertical && except.isVertical {
            return randomDirection(except: except)
        }
        
        return direction
    }
}

// Drawy stuff
extension PixelView {
    override func draw(_ dirtyRect: NSRect) {
        
        NSColor.black.set()
        NSBezierPath(rect: dirtyRect).fill()
        NSColor.white.set()
        
        let center = CGPoint(x: dirtyRect.midX, y: dirtyRect.midY)
        
        var circlePoint: CGPoint!
        
        
        let path = NSBezierPath()
        path.move(to: center)
        path.lineJoinStyle = .roundLineJoinStyle
        path.lineWidth = 1
        
        if lines.isEmpty {
            Swift.print("")
        }
        
        lines.forEach { line in
            let p = line.applying(CGAffineTransform(translationX: center.x + (path.lineWidth / 2), y: center.y + (path.lineWidth / 2)))
            circlePoint = p
            path.line(to: p)
        }
        
        if !lines.isEmpty {
            path.transform(using: AffineTransform(translationByX: -lines.last!.x, byY: -lines.last!.y))
        }
        
        path.stroke()
        
        if !lines.isEmpty {
            let size: CGFloat = 4
            let circle = NSBezierPath(ovalIn: CGRect(origin: circlePoint.applying(CGAffineTransform(translationX: -size / 2, y: -size / 2)), size: CGSize(width: size, height: size)))
            
            circle.appendRect(CGRect(origin: center.applying(CGAffineTransform(translationX: -size / 2 + (path.lineWidth / 2), y: -size / 2 + (path.lineWidth / 2))), size: CGSize(width: size, height: size)))
            circle.transform(using: AffineTransform(translationByX: -lines.last!.x, byY: -lines.last!.y))
            
            circle.fill()
        }
    }
}
