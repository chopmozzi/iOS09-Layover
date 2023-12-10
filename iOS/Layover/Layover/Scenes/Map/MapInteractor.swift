//
//  MapInteractor.swift
//  Layover
//
//  Created by kong on 2023/11/15.
//  Copyright © 2023 CodeBomber. All rights reserved.
//

import CoreLocation
import Foundation

protocol MapBusinessLogic {
    func checkLocationAuthorizationStatus()
    func playPosts(with: MapModels.PlayPosts.Request)

    @discardableResult
    func fetchPosts() -> Task<Bool, Never>

    @discardableResult
    func fetchPost(latitude: Double, longitude: Double) -> Task<Bool, Never>
    func selectVideo(with request: MapModels.SelectVideo.Request)
}

protocol MapDataStore {
    var postPlayStartIndex: Int? { get set }
    var posts: [Post]? { get set }
    var selectedVideoURL: URL? { get set }
}

final class MapInteractor: NSObject, MapBusinessLogic, MapDataStore {

    // MARK: - Properties

    typealias Models = MapModels
    var presenter: MapPresentationLogic?
    var videoFileWorker: VideoFileWorker?
    var worker: MapWorkerProtocol?

    private let locationManager = CLLocationManager()

    var postPlayStartIndex: Int?
    var posts: [Post]?
    var index: Int?
    var selectedVideoURL: URL?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func checkLocationAuthorizationStatus() {
        checkCurrentLocationAuthorization(for: locationManager.authorizationStatus)
    }

    func playPosts(with request: MapModels.PlayPosts.Request) {
        postPlayStartIndex = request.selectedIndex
        presenter?.presentPlaybackScene()
    }

    func fetchPosts() -> Task<Bool, Never> {
        Task {
            locationManager.startUpdatingLocation()
            guard let coordinate = locationManager.location?.coordinate else { return false }
            let posts = await worker?.fetchPosts(latitude: coordinate.latitude,
                                                 longitude: coordinate.longitude)
            guard let posts else { return false }
            self.posts = posts
            let response = Models.FetchPosts.Response(posts: posts)
            await MainActor.run {
                presenter?.presentFetchedPosts(with: response)
            }
            return true
        }
    }

    func fetchPost(latitude: Double, longitude: Double) -> Task<Bool, Never> {
        Task {
            let posts = await worker?.fetchPosts(latitude: latitude, longitude: longitude)
            guard let posts else { return false }
            self.posts = posts
            let response = Models.FetchPosts.Response(posts: posts)
            await MainActor.run {
                presenter?.presentFetchedPosts(with: response)
            }
            return true
        }
    }

    func selectVideo(with request: Models.SelectVideo.Request) {
        selectedVideoURL = videoFileWorker?.copyToNewURL(at: request.videoURL)
    }

    private func checkCurrentLocationAuthorization(for status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            presenter?.presentCurrentLocation()
        case .restricted, .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            presenter?.presentDefaultLocation()
        @unknown default:
            return
        }
    }
}

extension MapInteractor: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkCurrentLocationAuthorization(for: manager.authorizationStatus)
    }
}
