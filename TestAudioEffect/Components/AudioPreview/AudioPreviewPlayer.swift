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
    
    private var engine = AVAudioEngine()
    private var player = AVAudioPlayerNode()
    private var file: AVAudioFile? {
        willSet {
            self.player.stop()
        } didSet {
            guard let file = file else { return }
            let audioFormat = file.processingFormat
            let audioFrameCount = UInt32(file.length)
            guard let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount) else { return }
            try? file.read(into: audioFileBuffer)
            player.scheduleBuffer(audioFileBuffer, at: nil, options: loopMode ? .loops : [], completionHandler: { [weak self] in
                DispatchQueue.main.async {
                    if !(self?.loopMode ?? false) {
                        self?.stop()
                    }
                }
            })
        }
    }
    
    weak var delegate: AudioPreviewPlayerDelegate?
    
    private var session = SessionManager.default
    private weak var loadingTask: DownloadRequest?
    
    private(set) var loadingState: Operation.State = .unloaded {
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
    
    private(set) var playingPreview: AudioPreview?
    var loopMode: Bool = false
    
    override init() {
        super.init()
        connect(effectBuilder: nil)
    }
    
    func connect(effectBuilder: ((AVAudioEngine, AVAudioPlayerNode) -> AVAudioNode)?) {
        engine.stop()
        engine.attach(player)
        if let effects = effectBuilder?(engine, player) {
            engine.connect(player, to: effects, format: nil)
            engine.connect(effects, to: engine.mainMixerNode, format: nil)
        } else {
            engine.connect(player, to: engine.mainMixerNode, format: nil)
        }
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: nil)
        
        engine.prepare()
        try? engine.start()
    }
    
    func cancel() {
        loadingTask?.cancel()
        file = nil
    }
    
    func load(preview: AudioPreview, playAfterLoading: Bool = true) {
        guard let audioPreviewLink = preview.audioPreviewLink else { return }
        if preview == playingPreview && error == nil {
            if playAfterLoading {
                self.play()
            }
            return
        }
        stop()
        file = nil
        
        playingPreview = preview
        download(audioLink: audioPreviewLink) { [weak self] fileUrl, error in
            guard let `self` = self else { return }
            if let fileUrl = fileUrl, error != nil {
                self.loadFile(url: fileUrl, autoPlay: playAfterLoading)
            } else {
                self.error = error
            }
            self.loadingState = .loaded
        }
    }
    
    private func loadFile(url: URL, autoPlay: Bool) {
        do {
            file = try AVAudioFile(forReading: url)
            if autoPlay {
                self.play()
            }
        } catch {
            self.error = error
        }
    }
    
    func play() {
        if isPlaying { return }
        player.play()
        guard let loadedPreview = playingPreview else { return }
        delegate?.audioPlayer(self, didPlayPreview: loadedPreview)
    }
    
    func pause() {
        if !isPlaying { return }
        player.pause()
        guard let loadedPreview = playingPreview else { return }
        delegate?.audioPlayer(self, didPausePreview: loadedPreview)
    }
    
    func stop() {
        if !isPlaying { return }
        player.stop()
        guard let loadedPreview = playingPreview else { return }
        delegate?.audioPlayer(self, didStopPreview: loadedPreview)
    }
    
    var isPlaying: Bool {
        return loadingState == .loaded && player.isPlaying
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
    
    deinit {
        player.stop()
        engine.stop()
    }
}

extension AudioPreviewPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
    }
}