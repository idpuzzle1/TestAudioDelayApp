//
//  AudioPreview.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import UIKit

struct AudioPreview {
    
    let identifier:Int
    var name: String
    var thumb: UIImage?
    var audioPreview: Data?
    
    init(identifier: Int, name: String, thumb: UIImage? = nil, audioPreview: Data? = nil) {
        self.identifier = identifier
        self.name = name
        self.thumb = thumb
        self.audioPreview = audioPreview
    }
    
}
