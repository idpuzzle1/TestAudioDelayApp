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
    
    private var model = AudioEffectModel()
    
    var preview: AudioPreview? {
        get {
            return model.preview
        }
        set {
            model.preview = newValue
            guard let preview = newValue else { return }
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
        
        model.player.delegate = self
        touchDelayEffectView.currentPosition = Point(x: model.delay.feedback, y: model.delay.wetDryMix)
        
        guard let preview = preview else { return }
        updateView(preview: preview)
        navigationItem.title = preview.name
        
        audioPreviewView.isLoading = model.player.loadingState == .loading
        audioPreviewView.isPlaying = model.player.isPlaying
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


extension AudioEffectViewController: AudioPreviewViewDelegate {
    func previewDidPlay(_ view: AudioPreviewView) {
        model.player.play()
    }
    
    func previewDidPause(_ view: AudioPreviewView) {
        model.player.pause()
    }
}

extension AudioEffectViewController: TouchSquareViewDelegate {
    func touchSquare(_ view: TouchSquareView, didUpdatePosition position: Point) {
        model.delay = Delay(feedback: position.x, wetDryMix: position.y)
    }
}

extension AudioEffectViewController: AudioPreviewPlayerDelegate {
    func audioPlayerDidUnload(_ player: AudioPreviewPlayer) {
        audioPreviewView.isLoading = false
        audioPreviewView.isPlaying = false
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didStartLoadingPreview preview: AudioPreview) {
        audioPreviewView.isLoading = true
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didLoadPreview preview: AudioPreview) {
        audioPreviewView.isLoading = false
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didFailLoadingPreview preview: AudioPreview, error: Error) {
        player.stop()
        showErrorAlert(error: error)
        audioPreviewView.isLoading = false
        audioPreviewView.isPlaying = false
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didPlayPreview preview: AudioPreview) {
        audioPreviewView.isPlaying = true
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didPausePreview preview: AudioPreview) {
        audioPreviewView.isPlaying = false
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didStopPreview preview: AudioPreview) {
        audioPreviewView.isPlaying = false
    }
}
