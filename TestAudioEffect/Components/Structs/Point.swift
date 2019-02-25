//
//  Point.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 25/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import Foundation

struct Point: Equatable {
    var x: Float
    var y: Float
    
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
        
    static var zero: Point {
        return Point(x: 0, y: 0)
    }
    
    public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
