//
//  AudioEffectModel.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 25/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import AVFoundation

struct Delay {
    static let feedbackRange = Range(min: 0, max: 100)
    static let wetDryMixRange = Range(min: 0, max: 100)
    
    var feedback: Float
    var wetDryMix: Float
}

class AudioEffectModel {
    
    var player = AudioPreviewPlayer()
    private var delayNode = AVAudioUnitDelay()
    
    var preview: AudioPreview? {
        get {
            return player.playingPreview
        }
        set {
            if let newPreview = newValue {
                player.load(preview: newPreview, playAfterLoading: false)
            }
        }
    }
    
    init() {
        let delayNode = self.delayNode
        player.loopMode = true
        player.connect { (engine, player) -> AVAudioNode in
            engine.attach(delayNode)
            engine.connect(player, to: delayNode, format: nil)
            return delayNode
        }
        
    }
    
    var delay = Delay(feedback: 50, wetDryMix: 50) {
        didSet {
            delayNode.feedback = min(max(Delay.feedbackRange.min, delay.feedback), Delay.feedbackRange.max)
            delayNode.wetDryMix = min(max(Delay.wetDryMixRange.min, delay.wetDryMix), Delay.wetDryMixRange.max)
        }
    }
}
