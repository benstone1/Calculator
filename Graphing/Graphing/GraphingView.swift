//
//  GraphingView.swift
//  Graphing
//
//  Created by C4Q  on 6/19/17.
//  Copyright © 2017 C4Q . All rights reserved.
//

import UIKit
import Foundation

class GraphingView: UIView {
    
    func derivativeOf(fn: (Double)->Double, atX x: Double) -> Double {
        let h = 0.0000001
        return (fn(x + h) - fn(x))/h
    }


    private let axesDrawer = AxesDrawer()
    private var scaleWasSetByUser = false
    private var userUpdatedScale: CGFloat = 1.0

    
    enum functionType {
        case constant(Double)
        case function((Double) -> Double)
    }
    
    var userFunction: functionType = .function(sin)
    
    var scale: CGFloat {
        get {
            return scaleWasSetByUser ? userUpdatedScale : contentScaleFactor
        }
        set (newValue) {
            userUpdatedScale = newValue
            scaleWasSetByUser = true
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        axesDrawer.drawAxes(in: self.frame, origin: self.center, pointsPerUnit: scale)
        let axesPath = UIBezierPath(rect: rect)
        axesPath.stroke()
        
        pathForFunction(in: self.frame, origin: self.center, pointsPerUnit: scale).stroke()
    }
    
    func pathForFunction(in rect: CGRect, origin: CGPoint, pointsPerUnit: CGFloat) -> UIBezierPath {
        UIColor.black.set()
        let path = UIBezierPath()
        
        enum Direction {
            case left
            case right
        }
        
        func drawCurve(direction: Direction, f: (Double) -> Double) {
            print("Going \(direction)")
            for currentXValue in stride(from: origin.x, to: (direction == .right ? rect.maxX : rect.minX), by: direction == .right ? 0.1 : -0.1) {
                let newPoint = CGPoint(x: (currentXValue * scale) - (origin.x * (scale - 1)), y: origin.y - CGFloat(f(Double(currentXValue - origin.x))) * scale)
                path.addLine(to: newPoint)
                path.move(to: newPoint)
                print(newPoint)
            }
        }
        
        switch userFunction {
        case .constant(let value):
            path.move(to: CGPoint(x: Double(rect.minX), y: value))
            path.addLine(to: CGPoint(x: Double(rect.maxX), y: value))
        case .function(let f):
            let yIntercept = CGPoint(x: Double(origin.x), y: Double(origin.y) - f(0))
            print("y Intercept: \(yIntercept)")
            print("Origin? : \(origin)")
            path.move(to: yIntercept)
            drawCurve(direction: .right, f: f)
            path.move(to: yIntercept)
            drawCurve(direction: .left, f: f)
        }
        print(scale)
        return path
    }
    
    
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
}
