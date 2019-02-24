//
//  TouchSquareView.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import UIKit

struct Point {
    var x: Float
    var y: Float
    
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    init(cgPoint: CGPoint) {
        self.init(x: Float(cgPoint.x), y: Float(cgPoint.y))
    }
    
    var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

struct Range {
    var min: Float
    var max: Float
    
    static var zero: Range {
        return Range(min: 0, max: 0)
    }
    
    func scale(value: Float, to range: Range) -> Float {
        return ((value - range.min) * (self.max - self.min)/(range.max - range.min)) + self.min
    }
}

struct FlatRange {
    var horizontal: Range
    var vertical: Range
    
    init(horizontal: Range, vertical: Range) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    init(minX: Float, minY: Float, maxX: Float, maxY: Float) {
        self.init(horizontal: Range(min: minX, max: minX), vertical: Range(min: minY, max: maxY))
    }
    
    init(cgRect: CGRect) {
        self.init(minX: Float(cgRect.minX), minY: Float(cgRect.minY), maxX: Float(cgRect.maxX), maxY: Float(cgRect.maxY))
    }
    
    static var zero: FlatRange {
        return FlatRange(horizontal: .zero, vertical: .zero)
    }
    
    func scale(point: Point, to flatRange: FlatRange) -> Point {
        return Point(x: horizontal.scale(value: point.x, to: flatRange.horizontal), y: vertical.scale(value: point.y, to: flatRange.vertical))
    }
}

@IBDesignable
class TouchSquareView: UIView {
    var range: FlatRange = FlatRange(minX: -1, minY: -1, maxX: 1, maxY: 1)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private func setupView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        addGestureRecognizer(gesture)
    }
    
    override func draw(_ rect: CGRect) {
        if let tapPoint = tapPoint {
            let frameRange = FlatRange(cgRect: rect)
            let convertedPoint = range.scale(point: tapPoint, to: frameRange)
            let path = UIBezierPath(arcCenter: convertedPoint.cgPoint, radius: 8, startAngle: 0, endAngle: CGFloat.pi, clockwise: false)
            path.lineWidth = 2
            UIColor.black.setStroke()
            path.stroke()
        }
        super.draw(rect)
    }
    
    private var tapPoint: Point?
    @objc private func tap(gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            tapPoint = Point(cgPoint: gesture.location(in: self))
        case .possible, .cancelled, .ended, .failed:
            tapPoint = nil
        }
    }
}
