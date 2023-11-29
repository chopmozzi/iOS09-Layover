//
//  PlaybackModels.swift
//  Layover
//
//  Created by 황지웅 on 11/17/23.
//  Copyright © 2023 CodeBomber. All rights reserved.
//

import Foundation

enum PlaybackModels {
    // MARK: - Properties Type
    struct Board: Hashable {
        var id: UUID = UUID()
        let title: String
        let content: String
        let tags: [String]
        let sdUrl: URL
        let hdURL: URL
        let memeber: MemberDTO
    }

    enum ParentView {
        case home
        case other
    }

    // MARK: - Use Cases

    enum LoadPlaybackVideoList {
        struct Request {
            
        }

        struct Response {
            let videos: [Board]
        }

        struct ViewModel {
            let videos: [Board]
        }
    }

    enum DisplayPlaybackVideo {
        struct Request {
            let indexPathRow: Int?
            let curCell: PlaybackCell?
        }

        struct Response {
            let prevCell: PlaybackCell?
            let curCell: PlaybackCell?
        }

        struct ViewModel {
            let prevCell: PlaybackCell?
            let curCell: PlaybackCell?
        }
    }

    enum SetInitialPlaybackCell {
        struct Request {

        }

        struct Response {
            let indexPathRow: Int
        }

        struct ViewModel {
            let indexPathRow: Int
        }
    }

}
