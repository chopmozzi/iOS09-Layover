//
//  PlaybackViewController.swift
//  Layover
//
//  Created by 황지웅 on 11/15/23.
//  Copyright © 2023 CodeBomber. All rights reserved.
//

import UIKit
import AVFoundation

protocol PlaybackDisplayLogic: AnyObject {
    func displayVideoList(viewModel: PlaybackModels.LoadPlaybackVideoList.ViewModel)
    func displayMoveCellIfinfinite()
    func stopPrevPlayerAndPlayCurPlayer(viewModel: PlaybackModels.DisplayPlaybackVideo.ViewModel)
    func setInitialPlaybackCell(viewModel: PlaybackModels.SetInitialPlaybackCell.ViewModel)
    func moveInitialPlaybackCell(viewModel: PlaybackModels.SetInitialPlaybackCell.ViewModel)
    func hidePlayerSlider(viewModel: PlaybackModels.DisplayPlaybackVideo.ViewModel)
    func showPlayerSlider(viewModel: PlaybackModels.DisplayPlaybackVideo.ViewModel)
    func teleportPlaybackCell(viewModel: PlaybackModels.DisplayPlaybackVideo.ViewModel)
}

final class PlaybackViewController: BaseViewController {

    // MARK: - Type

    enum Section {
        case main
    }

    // MARK: - UI Components

    private let playbackCollectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()

    // MARK: - Properties

    private var dataSource: UICollectionViewDiffableDataSource<Section, Models.Board>?

    private var prevPlaybackCell: PlaybackCell?

    private var checkTelePort: Bool = false

    typealias Models = PlaybackModels
    var router: (NSObjectProtocol & PlaybackRoutingLogic & PlaybackDataPassing)?
    var interactor: PlaybackBusinessLogic?

    // MARK: - Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        PlaybackConfigurator.shared.configure(self)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        interactor?.displayVideoList()
        playbackCollectionView.delegate = self
        playbackCollectionView.contentInsetAdjustmentBehavior = .never
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interactor?.setInitialPlaybackCell()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        prevPlaybackCell?.playbackView.playerSlider.isHidden = true
        prevPlaybackCell?.playbackView.stopPlayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        interactor?.moveInitialPlaybackCell()
    }

    // MARK: - UI + Layout

    override func setConstraints() {
        playbackCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playbackCollectionView)
        NSLayoutConstraint.activate([
            playbackCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            playbackCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playbackCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playbackCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}

extension PlaybackViewController: PlaybackDisplayLogic {
    func displayVideoList(viewModel: Models.LoadPlaybackVideoList.ViewModel) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Models.Board>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.videos)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    func displayMoveCellIfinfinite() {
        playbackCollectionView.setContentOffset(.init(x: playbackCollectionView.contentOffset.x, y: playbackCollectionView.bounds.height), animated: false)
    }

    func stopPrevPlayerAndPlayCurPlayer(viewModel: PlaybackModels.DisplayPlaybackVideo.ViewModel) {
        if let prevCell = viewModel.prevCell {
            prevCell.playbackView.stopPlayer()
            prevCell.playbackView.replayPlayer()
        }
        if let curCell = viewModel.curCell {
            curCell.playbackView.playPlayer()
            curCell.playbackView.playerSlider.isHidden = false
        }
    }

    func setInitialPlaybackCell(viewModel: PlaybackModels.SetInitialPlaybackCell.ViewModel) {
        guard let currentPlaybackCell: PlaybackCell = playbackCollectionView.cellForItem(at: IndexPath(row: viewModel.indexPathRow, section: 0)) as? PlaybackCell else {
            return
        }
        let request: Models.DisplayPlaybackVideo.Request = Models.DisplayPlaybackVideo.Request(indexPathRow: nil, curCell: currentPlaybackCell)
        interactor?.playInitialPlaybackCell(with: request)
    }

    func hidePlayerSlider(viewModel: PlaybackModels.DisplayPlaybackVideo.ViewModel) {
        if let prevCell = viewModel.prevCell {
            prevCell.playbackView.playerSlider.isHidden = true
        }
    }

    func showPlayerSlider(viewModel: PlaybackModels.DisplayPlaybackVideo.ViewModel) {
        if let curCell = viewModel.curCell {
            curCell.playbackView.playerSlider.isHidden = false
        }
    }

    func moveInitialPlaybackCell(viewModel: PlaybackModels.SetInitialPlaybackCell.ViewModel) {
        let willMoveLocation: CGFloat = CGFloat(viewModel.indexPathRow) * playbackCollectionView.bounds.height
        playbackCollectionView.setContentOffset(.init(x: playbackCollectionView.contentOffset.x, y: willMoveLocation), animated: false)
    }

    func teleportPlaybackCell(viewModel: PlaybackModels.DisplayPlaybackVideo.ViewModel) {
        guard let indexPathRow = viewModel.indexPathRow else { return }
        let willTeleportlocation: CGFloat = CGFloat(indexPathRow) * playbackCollectionView.bounds.height
        playbackCollectionView.setContentOffset(.init(x: playbackCollectionView.contentOffset.x, y: willTeleportlocation), animated: false)
    }
}

// MARK: - Playback Method

private extension PlaybackViewController {
    func configureDataSource() {
        guard let tabbarHeight: CGFloat = self.tabBarController?.tabBar.frame.height else {
            return
        }
        playbackCollectionView.register(PlaybackCell.self, forCellWithReuseIdentifier: PlaybackCell.identifier)
        dataSource = UICollectionViewDiffableDataSource<Section, Models.Board>(collectionView: playbackCollectionView) { (collectionView, indexPath, video) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaybackCell.identifier, for: indexPath) as? PlaybackCell else { return PlaybackCell() }
            cell.setPlaybackContents(viewModel: video)
            cell.addAVPlayer(url: video.hdURL)
            cell.setPlayerSlider(tabbarHeight: tabbarHeight)
            return cell
        }
    }

//    func transDataForInfiniteScroll(_ videos: [VideoModel]) -> [VideoModel] {
//        /// Home과 Home을 제외한 나머지(맵, 프로필, 태그)의 무한 스크롤 동작이 다름
//        /// Home은 내릴 때마다 Video호출 필요, 나머지는 정해진 양이 있음
//        /// Home일 경우는 첫번 째 cell일 때 위로 안올라감.
//        /// 모든 동영상을 다 지나쳐야 첫번째 cell로 이동
//        var transVideos: [VideoModel] = videos
//        if transVideos.count > 0 {
//            var tempLastVideoModel: VideoModel = transVideos[transVideos.count-1]
//            tempLastVideoModel.id = UUID()
//            var tempFirstVideoModel: VideoModel = transVideos[1]
//            tempFirstVideoModel.id = UUID()
//            transVideos.insert(tempLastVideoModel, at: 0)
//            transVideos.append(tempFirstVideoModel)
//        }
//        return transVideos
//    }

    func moveCellAtInfiniteScroll(_ scrollView: UIScrollView) {
//        // ViewType이 Home이 아닌 경우
//        let count: Int = videos.count
//        if count == 0 {
//            return
//        }
//        if viewType == .home {
//            // 마지막 Cell에 도달하면 비디오 추가 로드
//            // 마지막 Video까지 다 재생했다면 다른 ViewType과 마찬가지로 동작 시작
//        }
        // 첫번째에 위치한 마지막 cell에 도달했을 때
//        if scrollView.contentOffset.y == 0 {
//            scrollView.setContentOffset(.init(x: scrollView.contentOffset.x, y: playbackCollectionView.bounds.height * Double(count - 2)), animated: false)
//            checkTelePort = true
//        } else if scrollView.contentOffset.y == Double(count-1) * playbackCollectionView.bounds.height {
//            scrollView.setContentOffset(.init(x: scrollView.contentOffset.x, y: playbackCollectionView.bounds.height), animated: false)
//            checkTelePort = true
//        } else {
//            normalPlayerScroll(scrollView)
//        }

    }

    func normalPlayerScroll(_ scrollView: UIScrollView) {
        let indexPathRow: Int = Int(scrollView.contentOffset.y / playbackCollectionView.frame.height)
        guard let currentPlaybackCell: PlaybackCell = playbackCollectionView.cellForItem(at: IndexPath(row: indexPathRow, section: 0)) as? PlaybackCell else {
            return
        }
        stopPrevPlayerAndPlayCurrnetPlayer(currentPlaybackCell)
        checkTelePort = false
    }

    func initPrevPlayerCell() {
        if prevPlaybackCell == nil {
            prevPlaybackCell = playbackCollectionView.cellForItem(at: IndexPath(row: 1, section: 0)) as? PlaybackCell
        }
        prevPlaybackCell?.playbackView.playerSlider.isHidden = false
        prevPlaybackCell?.playbackView.playPlayer()
    }

    func stopPrevPlayerAndPlayCurrnetPlayer(_ currentPlaybackCell: PlaybackCell) {
        if prevPlaybackCell != currentPlaybackCell {
            prevPlaybackCell?.playbackView.stopPlayer()
            prevPlaybackCell?.playbackView.replayPlayer()
            currentPlaybackCell.playbackView.playPlayer()
            prevPlaybackCell = currentPlaybackCell
            currentPlaybackCell.playbackView.playerSlider.isHidden = false
        }
    }
}

extension PlaybackViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension PlaybackViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indexPathRow: Int = Int(scrollView.contentOffset.y / playbackCollectionView.frame.height)
        guard let currentPlaybackCell: PlaybackCell = playbackCollectionView.cellForItem(at: IndexPath(row: indexPathRow, section: 0)) as? PlaybackCell else {
            return
        }
        let request: Models.DisplayPlaybackVideo.Request = Models.DisplayPlaybackVideo.Request(indexPathRow: indexPathRow, curCell: currentPlaybackCell)
        interactor?.playVideo(with: request)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        interactor?.hidePlayerSlider()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let currentPlaybackCell: PlaybackCell = cell as? PlaybackCell else {
            return
        }

        let request: Models.DisplayPlaybackVideo.Request = Models.DisplayPlaybackVideo.Request(indexPathRow: indexPath.row, curCell: currentPlaybackCell)
        interactor?.playTeleportVideo(with: request)
    }
}
//#Preview {
//    PlaybackViewController()
//}
