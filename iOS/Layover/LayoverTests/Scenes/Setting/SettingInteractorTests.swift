//
//  SettingInteractorTests.swift
//  Layover
//
//  Created by 김인환 on 12/13/23.
//  Copyright (c) 2023 CodeBomber. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import Layover
import XCTest

final class SettingInteractorTests: XCTestCase {
    // MARK: Subject under test

    var sut: SettingInteractor!

    typealias Models = SettingModels

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        setupSettingInteractor()
    }

    // MARK: - Test setup

    func setupSettingInteractor() {
        sut = SettingInteractor()
        sut.userWorker = MockUserWorker()
        sut.settingWorker = MockSettingWorker()
    }

    // MARK: - Test doubles

    final class SettingPresentationLogicSpy: SettingPresentationLogic {
        var presentTableViewCalled = false
        var presentTableViewResponse: Models.ConfigureTableView.Response!
        var presentUserLogoutConfirmedCalled = false
        var presentUserWithdrawConfirmedCalled = false

        func presentTableView(with response: Models.ConfigureTableView.Response) {
            presentTableViewCalled = true
            presentTableViewResponse = response
        }

        func presentUserLogoutConfirmed(with response: Models.Logout.Response) {
            presentUserLogoutConfirmedCalled = true
        }

        func presentUserWithdrawConfirmed(with response: Models.Withdraw.Response) {
            presentUserWithdrawConfirmedCalled = true
        }


    }

    // MARK: - Tests

    func test_performTableViewConfigure를_실행하면_presenter의_presentTableView가_호출되고_versionNumber를_전달한다() {
        // arrange
        let spy = SettingPresentationLogicSpy()
        sut.presenter = spy
        let request = Models.ConfigureTableView.Request()

        // act
        sut.performTableViewConfigure(request: request)

        // assert
        XCTAssertTrue(spy.presentTableViewCalled, "performTableViewConfigure()를 실행해서 presentTableView()를 호출되지 못했다.")
        XCTAssertTrue(spy.presentTableViewResponse.versionNumber == "7.7.7", "presentTableView()를 실행해서 올바른 versionNumber가 전달되지 못했다.")
    }

    func test_performUserLogout를_실행하면_presenter의_presentUserLogoutConfirmed가_호출된다() {
        // arrange
        let spy = SettingPresentationLogicSpy()
        sut.presenter = spy
        let request = Models.Logout.Request()

        // act
        sut.performUserLogout(request: request)

        // assert
        XCTAssertTrue(spy.presentUserLogoutConfirmedCalled, "performUserLogout()를 실행해서 presenter의 presentUserLogoutConfirmed()를 호출되지 못했다.")
    }

    func test_performUserWithdraw를_실행하면_presenter의_presentUserWithdrawConfirmed가_호출된다() async throws {
        // arrange
        let spy = SettingPresentationLogicSpy()
        sut.presenter = spy
        let request = Models.Withdraw.Request()

        // act
        sut.performUserWithdraw(request: request)
        try await Task.sleep(nanoseconds: 3_000_000_000)

        // assert
        XCTAssertTrue(spy.presentUserWithdrawConfirmedCalled, "performUserWithdraw()를 실행해서 presenter의 presentUserWithdrawConfirmed()가 호출되지 못했다.")
    }
}
