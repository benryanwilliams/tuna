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
    let id: ItemsID
    let snippet: Snippet?
    let statistics: Statistics?
}

struct ItemsID: Codable {
    let idString: String?
    let idMoreItems: IDMoreItems?

    // Determine whether 'id' is a string or a container containing more items
    init(from decoder: Decoder) throws {
        let container =  try decoder.singleValueContainer()

        // Check for a string
        do {
            idString = try container.decode(String.self)
            idMoreItems = nil
        } catch {
            // Check for more items
            idMoreItems = try container.decode(IDMoreItems.self)
            idString = nil
        }
    }

    // Convert back to dynamic type, so based on the data we have stored, encode to the proper type
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try (idString != nil) ? container.encode(idMoreItems) : container.encode(false)
    }
}


struct IDMoreItems: Codable {
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

struct Statistics: Codable {
    let viewCount: String?
}

