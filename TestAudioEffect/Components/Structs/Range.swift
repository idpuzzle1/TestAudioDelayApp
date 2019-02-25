//
//  Range.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 25/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

struct Range {
    var min: Float
    var max: Float
    
    static var zero: Range {
        return Range(min: 0, max: 0)
    }
    
    func scale(value: Float, from range: Range) -> Float {
        let valueRangeDiff = range.max - range.min
        let selfRangeDiff = self.max - self.min
        return ((value - range.min) * selfRangeDiff/valueRangeDiff) + self.min
    }
}
