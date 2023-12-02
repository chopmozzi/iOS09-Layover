//
//  HomeInteractor.swift
//  Layover
//
//  Created by 김인환 on 11/15/23.
//  Copyright © 2023 CodeBomber. All rights reserved.
//

import UIKit

protocol HomeBusinessLogic {
    func fetchPosts(with request: HomeModels.FetchPosts.Request)
    func fetchThumbnailImageData(with request: HomeModels.FetchThumbnailImageData.Request)
    func moveToPlaybackScene(with: HomeModels.MoveToPlaybackScene.Request)
    func selectVideo(with request: HomeModels.SelectVideo.Request)
}

protocol HomeDataStore {
    var posts: [Post]? { get set }
    var index: Int? { get set }
    var selectedVideoURL: URL? { get set }
}

final class HomeInteractor: HomeDataStore {

    // MARK: - Properties

    typealias Models = HomeModels

    var videoFileWorker: VideoFileWorkerProtocol?
    var homeWorker: HomeWorkerProtocol?
    var presenter: HomePresentationLogic?

    // MARK: - DataStore

    var posts: [Post]?
    var index: Int?
    var selectedVideoURL: URL?

    func selectVideo(with request: Models.SelectVideo.Request) {
        selectedVideoURL = videoFileWorker?.copyToNewURL(at: request.videoURL)
    }
}

// MARK: - Use Case

extension HomeInteractor: HomeBusinessLogic {
    func fetchPosts(with request: Models.FetchPosts.Request) {
        Task {
            guard let posts = await homeWorker?.fetchPosts() else { return }
            let response = Models.FetchPosts.Response(posts: posts)

            await MainActor.run {
                presenter?.presentPosts(with: response)
            }
        }
    }

    func fetchThumbnailImageData(with request: HomeModels.FetchThumbnailImageData.Request) {
        Task {
            guard let imageData = await homeWorker?.fetchImageData(of: request.imageURL) else { return }
            let response = Models.FetchThumbnailImageData.Response(imageData: imageData,
                                                                   indexPath: request.indexPath)

            await MainActor.run {
                presenter?.presentThumbnailImage(with: response)
            }
        }
    }

    func moveToPlaybackScene(with request: Models.MoveToPlaybackScene.Request) {
        posts = request.videos
        index = request.index
        presenter?.presentPlaybackScene()
    }
}
