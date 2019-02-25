//
//  AudioPreviewsModel.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 25/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import Foundation

class AudioPreviewsModel {
    private(set) var player = AudioPreviewPlayer()
    private(set) var fetcher: AudioPreviewsFetcher
    
    init(responseQueue: DispatchQueue) {
        self.fetcher = LocalFileAudioPreviewsFetcher(responseQueue: responseQueue)
    }
}

class LocalFileAudioPreviewsFetcher: AudioPreviewsFetcher {
    enum LoadingError: Error {
        case noSuchFile
        case decodingError
    }
    
    private(set) var state: OperationState = .unloaded
    var previews: [AudioPreview] = []
    var lastLoadingError: Error? {
        didSet {
            guard let error = lastLoadingError else { return }
            self.delegate?.fetcher(self, didFailLoading: error)
        }
    }
    weak var delegate: AudioPreviewsFetcherDelegate?
    
    internal let decodingQueue = DispatchQueue(label: "Decoder-\(UUID.init().uuidString)")
    var reponseQueue: DispatchQueue?
    init(delegate: AudioPreviewsFetcherDelegate? = nil, responseQueue: DispatchQueue? = nil) {
        self.delegate = delegate
        self.reponseQueue = responseQueue
    }
    
    func load() {
        if state == .loading { return }
        state = .loading
        
        decode { [weak self] previews, error in
            guard let `self` = self else { return }
            self.state = .loaded
            self.reponseQueue?.async {
                if let previews = previews {
                    self.insertNewPreview(previews)
                } else {
                    self.lastLoadingError = error ?? LoadingError.decodingError
                }
            }
        }
    }
    
    private func decode(completion: @escaping ([AudioPreview]?, Error?) -> Void) {
        decodingQueue.async {
            let currentBundle = Bundle(for: type(of: self))
            if let responseJsonPath = currentBundle.url(forResource: "testFilesConfig.json", withExtension: nil),
                let data = try? Data(contentsOf: responseJsonPath){
                let decoder = JSONDecoder()
                if let previews = try? decoder.decode([AudioPreview?].self, from: data).compactMap({ $0 }) {
                    completion(previews, nil)
                    return
                } else {
                    completion(nil, LoadingError.decodingError)
                }
            } else {
                completion(nil, LoadingError.noSuchFile)
            }
        }
    }
    
    private func insertNewPreview(_ newPreviews: [AudioPreview]) {
        self.previews += newPreviews
        self.delegate?.fetcher(self, didLoadItems: newPreviews)
    }
}
