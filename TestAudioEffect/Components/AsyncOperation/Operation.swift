//
//  Net.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import Foundation

struct Operation {
    
}

extension Operation {
    enum State: Equatable {
        case unloaded
        case loading
        case loaded
        
        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.unloaded, .unloaded), (.loading, .loading), (.loaded, .loaded):
                return true
            default:
                return false
            }
        }
    }
}


