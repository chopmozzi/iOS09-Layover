//
//  PlaybackCell.swift
//  Layover
//
//  Created by 황지웅 on 11/24/23.
//  Copyright © 2023 CodeBomber. All rights reserved.
//

import UIKit
import AVFoundation

final class PlaybackCell: UICollectionViewCell {

    var boardID: Int?

    var playbackView: PlaybackView?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        resetObserver()
    }

    func setPlaybackContents(info: PlaybackModels.PlaybackInfo) {
        playbackView = nil
        boardID = info.boardID
        playbackView = PlaybackView(frame: .zero, content: info.content)
        playbackView?.descriptionView.titleLabel.text = info.title
        configure()
        playbackView?.descriptionView.setText(info.content)
        playbackView?.profileLabel.text = info.profileName
        playbackView?.tagStackView.resetTagStackView()
        info.tag.forEach { tag in
            playbackView?.tagStackView.addTag(tag)
        }
    }

    func addAVPlayer(url: URL) {
        playbackView?.resetPlayer()
        playbackView?.addAVPlayer(url: url)
        playbackView?.setPlayerSlider()
    }

    func addPlayerSlider(tabBarHeight: CGFloat) {
        playbackView?.addWindowPlayerSlider(tabBarHeight)

    }

    func resetObserver() {
        playbackView?.removeTimeObserver()
        playbackView?.removePlayerSlider()
    }

    private func configure() {
        guard let playbackView else { return }
        playbackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playbackView)
        NSLayoutConstraint.activate([
            playbackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            playbackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            playbackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playbackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
