//
//  AudioEffectViewController.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import UIKit

class AudioEffectViewController: UIViewController {
    
    @IBOutlet weak var audioPreviewView: AudioPreviewView! {
        didSet {
            audioPreviewView.delegate = self
        }
    }
    @IBOutlet weak var touchDelayEffectView: TouchSquareView! {
        didSet {
            touchDelayEffectView.delegate = self
        }
    }
    
    private var effectModel = AudioEffectModel()
    
    var preview: AudioPreview? {
        didSet {
            effectModel.preview = preview
            guard let preview = preview else { return }
            updateView(preview: preview)
        }
    }
    
    private func updateView(preview: AudioPreview) {
        guard view != nil else { return }
        audioPreviewView.audioName.text = preview.name
        if let thumbLink = preview.thumbLink {
            audioPreviewView.thumbImageView.af_setImage(withURL: thumbLink)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        touchDelayEffectView.range = FlatRange(horizontal: Delay.feedbackRange, vertical: Delay.wetDryMixRange)
        touchDelayEffectView.layer.borderWidth = 2
        touchDelayEffectView.layer.borderColor = UIColor.gray.cgColor
        touchDelayEffectView.layer.cornerRadius = 8
        touchDelayEffectView.clipsToBounds = true
        
        effectModel.player.delegate = self
        touchDelayEffectView.currentPosition = Point(x: effectModel.delay.feedback, y: effectModel.delay.wetDryMix)
        
        guard let preview = preview else { return }
        updateView(preview: preview)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


extension AudioEffectViewController: AudioPreviewViewDelegate {
    func previewDidPlay(_ view: AudioPreviewView) {
        effectModel.player.play()
    }
    
    func previewDidPause(_ view: AudioPreviewView) {
        effectModel.player.pause()
    }
}

extension AudioEffectViewController: TouchSquareViewDelegate {
    func touchSquare(_ view: TouchSquareView, didUpdatePosition position: Point) {
        effectModel.delay = Delay(feedback: position.x, wetDryMix: position.y)
    }
}

extension AudioEffectViewController: AudioPreviewPlayerDelegate {
    func audioPlayerDidUnload(_ player: AudioPreviewPlayer) {
        
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didStartLoadingPreview preview: AudioPreview) {
        
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didLoadPreview preview: AudioPreview) {
        
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didFailLoadingPreview preview: AudioPreview, error: Error) {
        player.stop()
        
        showErrorAlert(error: error)
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didPlayPreview preview: AudioPreview) {
        
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didPausePreview preview: AudioPreview) {
        
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didStopPreview preview: AudioPreview) {
        
    }
    
    
}
