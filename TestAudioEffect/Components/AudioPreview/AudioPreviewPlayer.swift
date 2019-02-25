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
    private var playerBuffer: AVAudioPCMBuffer? {
        willSet {
            self.player.stop()
        }
    }
    
    weak var delegate: AudioPreviewPlayerDelegate?
    
    private var session = SessionManager.default
    private weak var loadingTask: DownloadRequest?
    
    private(set) var loadingState: OperationState = .unloaded {
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
                delegate?.audioPlayer(self, didLoadPreview: loadedPreview)
            }
        }
    }
    var error: Error? {
        didSet {
            guard let loadedPreview = playingPreview, let error = error else { return }
            delegate?.audioPlayer(self, didFailLoadingPreview: loadedPreview, error: error)
        }
    }
    
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
        playerBuffer = nil
    }
    
    func load(preview: AudioPreview, playAfterLoading: Bool = true) {
        guard let audioPreviewLink = preview.audioPreviewLink else { return }
        if loadingState == .loaded, preview == playingPreview && error == nil {
            if playAfterLoading {
                self.play()
            }
            return
        }
        stop()
        playerBuffer = nil
        
        playingPreview = preview
        download(audioLink: audioPreviewLink) { [weak self] fileUrl, error in
            guard let `self` = self else { return }
            if let fileUrl = fileUrl, error == nil {
                self.loadFile(url: fileUrl, autoPlay: playAfterLoading)
            } else {
                self.error = error
            }
        }
    }
    
    private func loadFile(url: URL, autoPlay: Bool) {
        do {
            let file = try AVAudioFile(forReading: url)
            playerBuffer = try createBuffer(file: file)
            if autoPlay {
                self.play()
            }
        } catch {
            self.error = error
        }
    }
    
    private func createBuffer(file: AVAudioFile) throws -> AVAudioPCMBuffer? {
        let audioFormat = file.processingFormat
        let audioFrameCount = UInt32(file.length)
        guard let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount) else { return nil }
        try file.read(into: audioFileBuffer)
        return audioFileBuffer
    }
    
    func play() {
        if isPlaying { return }
        guard let playerBuffer = playerBuffer, loadingState == .loaded, error == nil else {
            if let playingPreview = playingPreview {
                load(preview: playingPreview, playAfterLoading: true)
            }
            return
        }
        guard let loadedPreview = playingPreview else { return }
        player.scheduleBuffer(playerBuffer, at: nil, options: loopMode ? .loops : [], completionHandler: { [weak self] in
            DispatchQueue.main.async {
                if !(self?.loopMode ?? false), loadedPreview == self?.playingPreview {
                    self?.stop()
                }
            }
        })
        player.play()
        
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
        let destinationPath = self.fileDestination(url: audioLink)
        if  FileManager.default.fileExists(atPath: destinationPath.path) {
            self.loadingState = .loaded
            completion(destinationPath, nil)
            return
        }
        self.loadingState = .loading
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (destinationPath, [.createIntermediateDirectories])
        }
        
        let request = session.download(audioLink, to: destination).response { response in
            self.loadingState = .loaded
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
