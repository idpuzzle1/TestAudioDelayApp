//
//  AudioPreviewsViewController.swift
//  TestAudioEffect
//
//  Created by Антон Уханкин on 24/02/2019.
//  Copyright © 2019 idpuzzle1. All rights reserved.
//

import UIKit

class AudioPreviewsViewController: UITableViewController {
    private struct Constants {
        static let cellIdentifier = "AudioPreviewCell"
    }
    
}

//MARK: - Data Source

internal extension AudioPreviewsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

//MARK: - Delegate

internal extension AudioPreviewsViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let audioCell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! AudioPreviewCell
        return audioCell
    }
}
