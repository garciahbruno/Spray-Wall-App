// RouteStorage.swift

import Foundation

class RouteStorage {
    static func getFileURL(for wallID: UUID) -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("routes_\(wallID).json")
    }

    static func save(_ routes: [Route], for wallID: UUID) {
        do {
            let data = try JSONEncoder().encode(routes)
            try data.write(to: getFileURL(for: wallID))
        } catch {
            print("Failed to save routes for wall \(wallID): \(error)")
        }
    }

    static func load(for wallID: UUID) -> [Route] {
        let url = getFileURL(for: wallID)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Route].self, from: data)
        } catch {
            print("No saved routes for wall \(wallID): \(error)")
            return []
        }
    }
} 
