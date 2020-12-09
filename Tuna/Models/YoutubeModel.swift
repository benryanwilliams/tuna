//
//  YoutubeModel.swift
//  Tuna
//
//  Created by Ben Williams on 09/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import Foundation


struct YoutubeModel: Codable {
    let kind: String?
    let etag: String?
    let pageInfo: PageInfo?
    let items: [Items]
}

struct PageInfo: Codable {
    let totalResults: Int?
    let resultsPerPage: Int?
}

struct Items: Codable {
    let kind: String?
    let etag: String?
    let id: ItemsID?
    let snippet: Snippet?
}

struct ItemsID: Codable {
    let kind: String?
    let videoId: String?
}

struct Snippet: Codable {
    let publishedAt: String?
    let channelId: String?
    let title: String?
    let description: String?
    let thumbnails: Thumbnails?
    let channelTitle: String?
    let publishTime: String?
}

struct Thumbnails: Codable {
    let medium: ThumbnailMedium?
    let high: ThumbnailHigh?
}

struct ThumbnailMedium: Codable {
    let url: String?
    let width: Int?
    let height: Int?
}

struct ThumbnailHigh: Codable {
    let url: String?
    let width: Int?
    let height: Int?
}
