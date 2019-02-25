//
//  TouchSquareView.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import UIKit

protocol TouchSquareViewDelegate: class {
    func touchSquare(_ view: TouchSquareView, didUpdatePosition position: Point)
}

@IBDesignable
class TouchSquareView: UIView {
    var range: FlatRange = FlatRange(minX: -1, minY: -1, maxX: 1, maxY: 1)
    
    private var tapCircleLayer: CAShapeLayer = {
        let circleSublayer = CAShapeLayer.init()
        circleSublayer.bounds = CGRect(x: 0, y: 0, width: 32, height: 32)
        circleSublayer.borderWidth = 2
        circleSublayer.borderColor = UIColor.gray.cgColor
        circleSublayer.cornerRadius = circleSublayer.bounds.width/2
        return circleSublayer
    }()
    var currentPosition: Point = .zero {
        didSet {
            if currentPosition != oldValue {
                updateTapCirclePosition()
                delegate?.touchSquare(self, didUpdatePosition: currentPosition)
            }
        }
    }
    
    weak var delegate: TouchSquareViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSublayers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSublayers()
    }
    
    private func setupSublayers() {
        layer.addSublayer(tapCircleLayer)
    }
    
    override func layoutSubviews() {
        updateTapCirclePosition()
        super.layoutSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard event?.type == UIEvent.EventType.touches, let firstFingerTouch = touches.first else {
            return
        }
        setTapPoint(for: firstFingerTouch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard event?.type == UIEvent.EventType.touches, let firstFingerTouch = touches.first else {
            return
        }
        setTapPoint(for: firstFingerTouch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        setTapPoint(for: nil)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        setTapPoint(for: nil)
    }
    
    private func setTapPoint(for touch: UITouch?) {
        guard let touch = touch else {
            return
        }
        let boundsRange = FlatRange(cgRect: bounds)
        let tapLocation = touch.location(in: self)
        currentPosition = range.scale(point: Point(cgPoint: tapLocation), from: boundsRange)
    }
    
    private func updateTapCirclePosition() {
        let boundsRange = FlatRange(cgRect: bounds)
        let tapLocation = boundsRange.scale(point: currentPosition, from: range).cgPoint
        if tapCircleLayer.position != tapLocation {
            tapCircleLayer.position = tapLocation
        }
    }
}

private extension Point {
    init(cgPoint: CGPoint) {
        self.init(x: Float(cgPoint.x), y: Float(cgPoint.y))
    }
    
    var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

private extension FlatRange {
    init(cgRect: CGRect) {
        let horizontal = Range(min: Float(cgRect.minX), max: Float(cgRect.maxX))
        let vertical = Range(min: Float(cgRect.minY), max: Float(cgRect.maxY))
        self.init(horizontal: horizontal, vertical: vertical)
    }
}
