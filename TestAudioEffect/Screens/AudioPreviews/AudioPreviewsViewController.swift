//
//  AudioPreviewsViewController.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPreviewsViewController: UITableViewController {
    private struct Constants {
        static let cellIdentifier = "AudioPreviewCell"
    }
    
    private var player = AudioPreviewPlayer()
    private var previewsFetcher: AudioPreviewsFetcher
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.previewsFetcher = LocalFileAudioPreviewsFetcher(responseQueue: .main)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.previewsFetcher.delegate = self
        self.player.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.previewsFetcher = LocalFileAudioPreviewsFetcher(responseQueue: .main)
        super.init(coder: aDecoder)
        self.previewsFetcher.delegate = self
        self.player.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewsFetcher.load()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.stop()
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let effectVC = segue.destination as? AudioEffectViewController, let choosenAudioCell = sender as? AudioPreviewCell {
            effectVC.preview = choosenAudioCell.preview
        }
        super.prepare(for: segue, sender: sender)
    }
    
}

//MARK: - Data Source

internal extension AudioPreviewsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previewsFetcher.previews.count
    }
}

//MARK: - Delegate

internal extension AudioPreviewsViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let audioCell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! AudioPreviewCell
        audioCell.preview = previewsFetcher.previews[indexPath.row]
        audioCell.delegate = self
        audioCell.audioPreviewView.isLoading = player.loadingState == .loading && player.playingPreview == audioCell.preview
        audioCell.audioPreviewView.isPlaying = player.isPlaying && player.playingPreview == audioCell.preview
        return audioCell
    }
}

//MARK: - Model Delegate

extension AudioPreviewsViewController: AudioPreviewsFetcherDelegate {
    func fetcher(_ model: AudioPreviewsFetcher, didLoadItems newItems: [AudioPreview]) {
        tableView.reloadData()
    }
    
    func fetcher(_ model: AudioPreviewsFetcher, didFailLoading error: Error) {
        showErrorAlert(error: error)
    }
}

extension AudioPreviewsViewController: AudioPreviewPlayerDelegate {
    func audioPlayerDidUnload(_ player: AudioPreviewPlayer) {
        stopPlaying()
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didStartLoadingPreview preview: AudioPreview) {
        startLoading(preview: preview)
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didLoadPreview preview: AudioPreview) {
        finishLoading(preview: preview)
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didFailLoadingPreview preview: AudioPreview, error: Error) {
        stopPlaying()
        showErrorAlert(error: error)
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didPlayPreview preview: AudioPreview) {
        startLoading(preview: preview)
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didPausePreview preview: AudioPreview) {
        stopPlaying()
    }
    
    func audioPlayer(_ player: AudioPreviewPlayer, didStopPreview preview: AudioPreview) {
        stopPlaying()
    }
    
    private func startLoading(preview: AudioPreview) {
        tableView.visibleCells.compactMap({$0 as? AudioPreviewCell}).filter({ $0.preview ==  preview}).forEach { cell in
            cell.audioPreviewView.isLoading = false
            cell.audioPreviewView.isPlaying = true
        }
    }
    
    private func finishLoading(preview: AudioPreview) {
        tableView.visibleCells.compactMap({$0 as? AudioPreviewCell}).filter({ $0.preview ==  preview}).forEach { cell in
            cell.audioPreviewView.isLoading = false
        }
    }
    
    private func startPlaying(preview: AudioPreview) {
        tableView.visibleCells.compactMap({$0 as? AudioPreviewCell}).filter({ $0.preview ==  preview}).forEach { cell in
            cell.audioPreviewView.isLoading = false
            cell.audioPreviewView.isPlaying = true
        }
    }
    
    private func stopPlaying() {
        tableView.visibleCells.compactMap({$0 as? AudioPreviewCell}).forEach { cell in
            cell.audioPreviewView.isLoading = false
            cell.audioPreviewView.isPlaying = false
        }
    }
}

//MARK: - Audio Cell Delegate

extension AudioPreviewsViewController: AudioPreviewCellDelegate {
    func previewCellDidPlay(_ cell: AudioPreviewCell) {
        guard let preview = cell.preview else { return }
        player.load(preview: preview, playAfterLoading: true)
    }
    
    func previewCellDidPause(_ cell: AudioPreviewCell) {
        if cell.preview == player.playingPreview {
            player.pause()
        }
    }
}


