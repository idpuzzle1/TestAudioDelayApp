//
//  AudioPreview.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import UIKit

struct AudioPreview: Codable {
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case thumbLink = "image"
        case audioPreviewLink = "audio"
    }
    
    let identifier:Int
    var name: String
    var thumbLink: URL?
    var audioPreviewLink: URL?
    
    init(identifier: Int, name: String, thumbLink: URL? = nil, audioPreviewLink: URL? = nil) {
        self.identifier = identifier
        self.name = name
        self.thumbLink = thumbLink
        self.audioPreviewLink = audioPreviewLink
    }
}

extension AudioPreview: Equatable {
    public static func == (lhs: AudioPreview, rhs: AudioPreview) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
