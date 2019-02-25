//
//  FlatRange.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 25/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

struct FlatRange {
    var horizontal: Range
    var vertical: Range
    
    init(horizontal: Range, vertical: Range) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    init(minX: Float, minY: Float, maxX: Float, maxY: Float) {
        self.init(horizontal: Range(min: minX, max: maxX), vertical: Range(min: minY, max: maxY))
    }
    
    static var zero: FlatRange {
        return FlatRange(horizontal: .zero, vertical: .zero)
    }
    
    func scale(point: Point, from flatRange: FlatRange) -> Point {
        return Point(x: horizontal.scale(value: point.x, from: flatRange.horizontal), y: vertical.scale(value: point.y, from: flatRange.vertical))
    }
}
