//
//  Response.swift
//  Virtual Tourist
//
//  Created by Renad nasser on 15/08/2020.
//  Copyright © 2020 Renad nasser. All rights reserved.
//

import Foundation
struct Response: Codable {
        let photos: Photos
        let stat: String
    }

    // MARK: - Photos
    struct Photos: Codable {
        let page, pages, perpage: Int
        let total: String
        let photo: [Image]
    }

    // MARK: - Image
    struct Image: Codable {
        let id, owner, secret, server: String
        let farm: Int
        let title: String
        let ispublic, isfriend, isfamily: Int
        let urlM: String
        let heightM, widthM: Int

        enum CodingKeys: String, CodingKey {
            case id, owner, secret, server, farm, title, ispublic, isfriend, isfamily
            case urlM = "url_m"
            case heightM = "height_m"
            case widthM = "width_m"
        }
    }

