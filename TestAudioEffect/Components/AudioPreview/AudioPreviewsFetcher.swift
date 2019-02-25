//
//  AudioPreviewsFetcher.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import Alamofire
import CodableAlamofire

protocol AudioPreviewsFetcher: class {
    var state: OperationState { get }
    var previews: [AudioPreview] { get }
    var lastLoadingError: Error? { get }
    
    var delegate: AudioPreviewsFetcherDelegate? { get set }
    func load()
}

protocol AudioPreviewsFetcherDelegate: class {
    func fetcher(_ fetcher: AudioPreviewsFetcher, didLoadItems newItems:[AudioPreview])
    func fetcher(_ fetcher: AudioPreviewsFetcher, didFailLoading error: Error)
}
