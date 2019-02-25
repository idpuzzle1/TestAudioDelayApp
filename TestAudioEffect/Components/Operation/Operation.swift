//
//  Net.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import Foundation

enum OperationState: Equatable {
    case unloaded
    case loading
    case loaded
    
    public static func == (lhs: OperationState, rhs: OperationState) -> Bool {
        switch (lhs, rhs) {
        case (.unloaded, .unloaded), (.loading, .loading), (.loaded, .loaded):
            return true
        default:
            return false
        }
    }
}


