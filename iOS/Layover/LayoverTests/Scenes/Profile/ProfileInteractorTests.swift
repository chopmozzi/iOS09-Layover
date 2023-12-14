//
//  ProfileInteractorTests.swift
//  Layover
//
//  Created by 김인환 on 12/12/23.
//  Copyright (c) 2023 CodeBomber. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import Layover
import XCTest

final class ProfileInteractorTests: XCTestCase {
    // MARK: Subject under test

    var sut: ProfileInteractor!

    typealias Models = ProfileModels

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        setupProfileInteractor()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup

    func setupProfileInteractor() {
        sut = ProfileInteractor()
        sut.userWorker = MockUserWorker()
    }

    // MARK: - Test doubles

    final class ProfilePresentationLogicSpy: ProfilePresentationLogic {
        var presentProfileCalled = false
        var presentProfileResponse: Models.FetchProfile.Response!
        var presentMorePostsCalled = false
        var presentMorePostsResponse: Models.FetchMorePosts.Response!
        var presentPostDetailCalled = false
        var presentPostDetailResponse: Models.ShowPostDetail.Response!

        func presentProfile(with response: Models.FetchProfile.Response) {
            presentProfileCalled = true
            presentProfileResponse = response
        }

        func presentMorePosts(with response: Models.FetchMorePosts.Response) {
            presentMorePostsCalled = true
            presentMorePostsResponse = response
        }

        func presentPostDetail(with response: Models.ShowPostDetail.Response) {
            presentPostDetailCalled = true
            presentPostDetailResponse = response
        }
    }

    // MARK: - Tests

    func test_fetchProfile을_호출하면_presenter의_presentProfile을_호출하여_presentProfileResponse를_전달한다() async {
        // arrange
        let presentationLogicSpy = ProfilePresentationLogicSpy()
        sut.presenter = presentationLogicSpy

        // act
        await sut.fetchProfile(with: Models.FetchProfile.Request())

        // assert
        XCTAssertTrue(presentationLogicSpy.presentProfileCalled, "fetchProfile을 호출해서 presentProfile을 호출하지 못했다")
        XCTAssertEqual(presentationLogicSpy.presentProfileResponse.displayedPosts.count, 1, "presentProfileResponse에는 fetchProfile의 결과 갯수가 올바르게 담기지 못했다.")
        XCTAssertEqual(presentationLogicSpy.presentProfileResponse.displayedPosts[0].id, Seeds.Posts.post1.board.identifier, "presentProfileResponse에는 fetchProfile의 결과가 올바르게 담기지 못했다.")
        XCTAssertEqual(presentationLogicSpy.presentProfileResponse.displayedPosts[0].thumbnailImageData, Seeds.sampleImageData, "presentProfileResponse에는 fetchProfile의 결과가 올바르게 담기지 못했다.")
        XCTAssertEqual(presentationLogicSpy.presentProfileResponse.displayedPosts[0].status, Seeds.Posts.post1.board.status, "presentProfileResponse에는 fetchProfile의 결과가 올바르게 담기지 못했다.")
        XCTAssertEqual(presentationLogicSpy.presentProfileResponse.userProfile.username, Seeds.Members.getMember1.username, "presentProfileResponse에는 fetchProfile의 결과가 올바르게 담기지 못했다.")
        XCTAssertEqual(presentationLogicSpy.presentProfileResponse.userProfile.introduce, Seeds.Members.getMember1.introduce, "presentProfileResponse에는 fetchProfile의 결과가 올바르게 담기지 못했다.")
        XCTAssertEqual(presentationLogicSpy.presentProfileResponse.userProfile.profileImageData, Seeds.sampleImageData, "presentProfileResponse에는 fetchProfile의 결과가 올바르게 담기지 못했다.")
    }

    func test_fetchMorePosts을_호출하면_presenter의_presentMorePosts을_호출하고_presentMorePostsResponse를_전달한다() async {
        // arrange
        let presentationLogicSpy = ProfilePresentationLogicSpy()
        sut.presenter = presentationLogicSpy

        // act
        await sut.fetchMorePosts(with: Models.FetchMorePosts.Request())

        // assert
        XCTAssertTrue(presentationLogicSpy.presentMorePostsCalled, "fetchMorePosts을 호출해서 presentMorePosts을 호출하지 못했다")
        XCTAssertEqual(presentationLogicSpy.presentMorePostsResponse.displayedPosts.count, 1, "fetchMorePosts의 결과 갯수가 올바르게 담기지 못했다")
        XCTAssertEqual(presentationLogicSpy.presentMorePostsResponse.displayedPosts[0].id, Seeds.Posts.post1.board.identifier, "presentMorePostsResponse에는 fetchMorePosts의 결과가 올바르게 담기지 못했다")
        XCTAssertEqual(presentationLogicSpy.presentMorePostsResponse.displayedPosts[0].thumbnailImageData, Seeds.sampleImageData, "presentMorePostsResponse에는 fetchMorePosts의 결과가 올바르게 담기지 못했다")
        XCTAssertEqual(presentationLogicSpy.presentMorePostsResponse.displayedPosts[0].status, Seeds.Posts.post1.board.status, "presentMorePostsResponse에는 fetchMorePosts의 결과가 올바르게 담기지 못했다")
    }

    func test_showPostDetail을_호출하면_자신의_playbackStartIndex에_값을_저장하고_presenter의_presentPostDetail을_호출한다() {
        // arrange
        let presentationLogicSpy = ProfilePresentationLogicSpy()
        sut.presenter = presentationLogicSpy

        // act
        sut.showPostDetail(with: Models.ShowPostDetail.Request(startIndex: 7))

        // assert
        XCTAssertEqual(sut.playbackStartIndex, 7, "showPostDetail을 호출해서 playbackStartIndex에 값을 저장하지 못했다")
        XCTAssertTrue(presentationLogicSpy.presentPostDetailCalled, "showPostDetail을 호출해서 presentPostDetail을 호출하지 못했다")
    }
}