//
//  AudioPreviewPlayer.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import AVFoundation
import Alamofire

protocol AudioPreviewPlayerDelegate: class {
    func audioPlayerDidUnload(_ player: AudioPreviewPlayer)
    func audioPlayer(_ player: AudioPreviewPlayer, didStartLoadingPreview preview: AudioPreview)
    func audioPlayer(_ player: AudioPreviewPlayer, didLoadPreview preview: AudioPreview)
    func audioPlayer(_ player: AudioPreviewPlayer, didFailLoadingPreview preview: AudioPreview, error: Error)
    
    func audioPlayer(_ player: AudioPreviewPlayer, didPlayPreview preview: AudioPreview)
    func audioPlayer(_ player: AudioPreviewPlayer, didPausePreview preview: AudioPreview)
    func audioPlayer(_ player: AudioPreviewPlayer, didStopPreview preview: AudioPreview)
}

class AudioPreviewPlayer: NSObject {
    private var player: AVAudioPlayer?
    
    weak var delegate: AudioPreviewPlayerDelegate?
    
    private var session = SessionManager.default
    private var loadingTask: DownloadRequest?
    
    var loadingState: Operation.State = .unloaded {
        didSet {
            switch loadingState {
            case .unloaded:
                error = nil
                playingPreview = nil
                delegate?.audioPlayerDidUnload(self)
            case .loading:
                error = nil
                guard let loadedPreview = playingPreview else { return }
                delegate?.audioPlayer(self, didStartLoadingPreview: loadedPreview)
            case  .loaded:
                guard let loadedPreview = playingPreview else { return }
                if let error = error {
                    delegate?.audioPlayer(self, didFailLoadingPreview: loadedPreview, error: error)
                } else {
                    delegate?.audioPlayer(self, didLoadPreview: loadedPreview)
                }
            }
        }
    }
    var error: Error?
    
    var playingPreview: AudioPreview?
    func load(preview: AudioPreview, playAfterLoading: Bool = true) {
        guard let audioPreviewLink = preview.audioPreviewLink else { return }
        if preview == playingPreview && error == nil {
            if playAfterLoading {
                self.play()
            }
            return
        }
        stop()
        player = nil
        
        playingPreview = preview
        download(audioLink: audioPreviewLink) { [weak self] fileUrl, error in
            guard let `self` = self else { return }
            if let fileUrl = fileUrl, error != nil {
                self.loadPlayer(url: fileUrl, autoPlay: playAfterLoading)
            } else {
                self.error = error
            }
            self.loadingState = .loaded
        }
    }
    
    private func loadPlayer(url: URL, autoPlay: Bool) {
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            self.player?.delegate = self
            
            if autoPlay {
                self.play()
            }
        } catch {
            self.error = error
        }
    }
    
    func play() {
        player?.play()
        guard let loadedPreview = playingPreview else { return }
        delegate?.audioPlayer(self, didPlayPreview: loadedPreview)
    }
    
    func pause() {
        player?.pause()
        guard let loadedPreview = playingPreview else { return }
        delegate?.audioPlayer(self, didPausePreview: loadedPreview)
    }
    
    func stop() {
        player?.stop()
        guard let loadedPreview = playingPreview else { return }
        delegate?.audioPlayer(self, didStopPreview: loadedPreview)
    }
    
    var isPlaying: Bool {
        return loadingState == .loaded && player?.isPlaying ?? false
    }
    
    private func download(audioLink: URL, completion: @escaping (URL?, Error?) -> Void) {
        if loadingTask?.request?.url == audioLink && (loadingTask?.task?.state == .running) {
            return
        }
        self.loadingState = .loading
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (self.fileDestination(url: audioLink), [.createIntermediateDirectories])
        }
        
        let request = session.download(audioLink, to: destination).response(queue: .main) { response in
            completion(response.destinationURL, response.error)
        }
        self.loadingTask = request
    }
    
    private func fileDestination(url: URL) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("\(url.lastPathComponent)")
    }
}

extension AudioPreviewPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
    }
}
