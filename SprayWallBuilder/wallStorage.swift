//
//  wallStorage.swift
//  SprayWallBuilder
//
//  Created by Bruno Garcia on 5/14/25.
//

import Foundation

class WallStorage {
    static let filename = "walls.json"

    static private var fileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(filename)
    }

    static func save(_ walls: [Wall]) {
        do {
            let data = try JSONEncoder().encode(walls)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save walls:", error)
        }
    }

    static func load() -> [Wall] {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Wall].self, from: data)
        } catch {
            print("Failed to load walls:", error)
            return []
        }
    }
}

class WallViewModel: ObservableObject {
    @Published var walls: [Wall] = []
    func deleteWall(at offsets: IndexSet) {
        walls.remove(atOffsets: offsets)
        WallStorage.save(walls) // re-save after deletion
    }
    init() {
        walls = WallStorage.load()
    }

    func addWall(name: String, imageName: String) {
        let newWall = Wall(id: UUID(), name: name, imageName: imageName)
        walls.append(newWall)
        WallStorage.save(walls)
    }
}
