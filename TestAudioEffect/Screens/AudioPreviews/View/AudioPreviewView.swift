//
//  AudioPreviewView.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 25/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import UIKit
import AlamofireImage

protocol AudioPreviewViewDelegate: class {
    func previewDidPlay(_ view: AudioPreviewView)
    func previewDidPause(_ view: AudioPreviewView)
}

@IBDesignable
class AudioPreviewView: UIView {

    private struct Constants {
        static let playImage = "play"
        static let pauseImage = "pause"
    }
    
    weak var delegate: AudioPreviewViewDelegate?
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var audioLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playAudioButton: UIButton!
    @IBOutlet weak var audioName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }
    
    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AudioPreviewView", bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        subviews.first?.prepareForInterfaceBuilder()
    }
        
    var isLoading: Bool = false {
        didSet {
            audioLoadingIndicator.isHidden = !isLoading
            playAudioButton.isHidden = isLoading
        }
    }
    
    @IBAction func playPause(_ sender: Any) {
        isPlaying = !isPlaying
    }
    
    var isPlaying: Bool {
        get {
            return playAudioButton?.isSelected ?? false
        }
        set {
            guard isPlaying != newValue else { return }
            playAudioButton.isSelected = newValue
            notifyPlaying()
        }
    }
    
    private func notifyPlaying() {
        if isPlaying {
            delegate?.previewDidPlay(self)
        } else {
            delegate?.previewDidPause(self)
        }
    }
    
}
