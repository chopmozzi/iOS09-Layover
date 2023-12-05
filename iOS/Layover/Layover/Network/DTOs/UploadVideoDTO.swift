//
//  UploadVideoDTO.swift
//  Layover
//
//  Created by kong on 2023/12/05.
//  Copyright © 2023 CodeBomber. All rights reserved.
//

import Foundation

struct UploadVideoDTO: Decodable {
    let presignedUrl: String
}

struct UploadVideoRequestDTO: Encodable {
    let boardID: Int
    let filetype: String
}
