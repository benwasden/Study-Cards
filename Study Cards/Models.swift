//
//  Models.swift
//  Study Cards
//
//  Created by Benjamin Wasden on 2/13/26.
//

import Foundation

struct Card: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var term: String
    var definition: String
}

struct CardCollection: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var cards: [Card] = []
}
