//
//  AudioPreviewCell.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AVFoundation

protocol AudioPreviewCellDelegate: class {
    func audioCellDidPlay(_ cell: AudioPreviewCell)
    func audioCellDidPause(_ cell: AudioPreviewCell)
}

class AudioPreviewCell: UITableViewCell {
    
    private struct Constants {
        static let playImage = "play"
        static let pauseImage = "pause"
    }
    
    weak var delegate: AudioPreviewCellDelegate?
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var audioLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playAudioButton: UIButton!
    @IBOutlet weak var audioName: UILabel!
    
    var isLoading: Bool = false {
        didSet {
            audioLoadingIndicator.isHidden = !isLoading
            playAudioButton.isHidden = isLoading
        }
    }
    
    var preview: AudioPreview? {
        didSet {
            guard let preview = preview else { return }
            updateCell(preview: preview)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.af_cancelImageRequest()
        thumbImageView.image = nil
    }
    
    private func updateCell(preview: AudioPreview) {
        audioName.text = preview.name
        if let thumbLink = preview.thumbLink {
            thumbImageView.af_setImage(withURL: thumbLink)
        }
    }
    
    @IBAction func playPause(_ sender: Any) {
        isPlaying = !isPlaying
    }
    
    var isPlaying: Bool {
        get {
            return playAudioButton.isSelected
        }
        set {
            guard isPlaying != newValue else { return }
            playAudioButton.isSelected = newValue
            notifyPlaying()
        }
    }
    
    private func notifyPlaying() {
        if isPlaying {
            delegate?.audioCellDidPlay(self)
        } else {
            delegate?.audioCellDidPause(self)
        }
    }
}
