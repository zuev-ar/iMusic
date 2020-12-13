//
//  SearchResponse.swift
//  iMusic
//
//  Created by Arkasha Zuev on 22.10.2020.
//

import Foundation

struct SearchResponse: Decodable {
    var resultCount: Int
    var results: [Track]
}

struct Track: Decodable {
    var trackName: String
    var artistName: String
    var collectionName: String?
    var artworkUrl100: String?
    var previewUrl: String?
}
