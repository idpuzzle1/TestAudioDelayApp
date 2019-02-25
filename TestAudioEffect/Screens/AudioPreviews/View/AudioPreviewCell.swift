//
//  AudioPreviewCell.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import UIKit

protocol AudioPreviewCellDelegate: class {
    func previewCellDidPlay(_ cell: AudioPreviewCell)
    func previewCellDidPause(_ cell: AudioPreviewCell)
}

class AudioPreviewCell: UITableViewCell {
    
    weak var delegate: AudioPreviewCellDelegate?
    
    @IBOutlet weak var audioPreviewView: AudioPreviewView! {
        didSet {
            audioPreviewView.delegate = self
        }
    }
    
    var preview: AudioPreview? {
        didSet {
            guard let preview = preview else { return }
            updateView(preview: preview)
        }
    }
    
    private func updateView(preview: AudioPreview) {
        audioPreviewView.audioName.text = preview.name
        if let thumbLink = preview.thumbLink {
            audioPreviewView.thumbImageView.af_setImage(withURL: thumbLink)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        audioPreviewView.thumbImageView.af_cancelImageRequest()
    }
}

extension AudioPreviewCell: AudioPreviewViewDelegate {
    func previewDidPlay(_ view: AudioPreviewView) {
        delegate?.previewCellDidPlay(self)
    }
    
    func previewDidPause(_ view: AudioPreviewView) {
        delegate?.previewCellDidPause(self)
    }
    
    
}
