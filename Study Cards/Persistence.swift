//
//  Persistence.swift
//  Study Cards
//
//  Created by Benjamin Wasden on 2/12/26.
//

import Foundation

enum Persistence {
    static let collectionsDirectoryName = "Collections"

    private static func documentsDirectory() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: true)
    }

    private static func collectionsDirectoryURL() throws -> URL {
        let dir = try documentsDirectory().appendingPathComponent(collectionsDirectoryName, isDirectory: true)
        if (!FileManager.default.fileExists(atPath: dir.path)) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func urlForCollection(id: UUID) throws -> URL {
        try collectionsDirectoryURL().appendingPathComponent("collection-\(id.uuidString).json")
    }

    static func saveCollection(_ collection: CardCollection) throws {
        let url = try urlForCollection(id: collection.id)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(collection)
        try data.write(to: url, options: [.atomic])
    }

    static func loadCollection(id: UUID) throws -> CardCollection {
        let url = try urlForCollection(id: id)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(CardCollection.self, from: data)
    }

    static func listCollections() throws -> [CardCollection] {
        let dir = try collectionsDirectoryURL()
        let urls = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        let decoder = JSONDecoder()
        var results: [CardCollection] = []
        for url in urls where url.pathExtension.lowercased() == "json" {
            do {
                let data = try Data(contentsOf: url)
                let coll = try decoder.decode(CardCollection.self, from: data)
                results.append(coll)
            } catch {
                print("Failed to decore collection at (url.lastPathComponent): ", error)
            }
        }
        return results
    }

    static func deleteCollection(id: UUID) throws {
        let url = try urlForCollection(id: id)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
