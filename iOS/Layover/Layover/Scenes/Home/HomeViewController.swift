//
//  HomeViewController.swift
//  Layover
//
//  Created by 김인환 on 11/15/23.
//  Copyright © 2023 CodeBomber. All rights reserved.
//

import UIKit

protocol HomeDisplayLogic: AnyObject {
//    func displayFetchFromLocalDataStore(with viewModel: HomeModels.FetchFromLocalDataStore.ViewModel)
//    func displayFetchFromRemoteDataStore(with viewModel: HomeModels.FetchFromRemoteDataStore.ViewModel)
//    func displayTrackAnalytics(with viewModel: HomeModels.TrackAnalytics.ViewModel)
//    func displayPerformHome(with viewModel: HomeModels.PerformHome.ViewModel)
}

final class HomeViewController: BaseViewController, HomeDisplayLogic {

    // MARK: - Properties

    typealias Models = HomeModels
    var router: (HomeRoutingLogic & HomeDataPassing)?
    var interactor: HomeBusinessLogic?

    // MARK: - UI Components

    private let uploadButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(resource: .uploadButton)
        return UIButton(configuration: configuration)
    }()

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
        let viewController = self
        let interactor = HomeInteractor()
        let presenter = HomePresenter()
        let router = HomeRouter()

        viewController.router = router
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - UI

    override func setConstraints() {
        uploadButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubviews(uploadButton)

        NSLayoutConstraint.activate([
            uploadButton.rightAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            uploadButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            uploadButton.widthAnchor.constraint(equalToConstant: 52),
            uploadButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    // MARK: - Use Case

    // MARK: - Use Case - Fetch From Remote DataStore

    @IBOutlet var exampleRemoteLabel: UILabel! = UILabel()
    func setupFetchFromRemoteDataStore() {
        let request = Models.FetchFromRemoteDataStore.Request()
        interactor?.fetchFromRemoteDataStore(with: request)
    }

    func displayFetchFromRemoteDataStore(with viewModel: HomeModels.FetchFromRemoteDataStore.ViewModel) {
        exampleRemoteLabel.text = viewModel.exampleVariable
    }

    // MARK: - Use Case - Track Analytics

    @objc
    func trackScreenViewAnalytics() {
        trackAnalytics(event: .screenView)
    }

    func trackAnalytics(event: HomeModels.AnalyticsEvents) {
        let request = Models.TrackAnalytics.Request(event: event)
        interactor?.trackAnalytics(with: request)
    }

    func displayTrackAnalytics(with viewModel: HomeModels.TrackAnalytics.ViewModel) {
        // do something after tracking analytics (if needed)
    }

    // MARK: - Use Case - Home

    func performHome(_ sender: Any) {

    }

    func displayPerformHome(with viewModel: HomeModels.PerformHome.ViewModel) {

    }
}
