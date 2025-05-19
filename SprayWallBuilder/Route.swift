
import Foundation
import SwiftUI

struct Hold: Identifiable, Codable, Equatable {
    let id: UUID
    var x: CGFloat      // 0.0 to 1.0 (relative X position)
    var y: CGFloat      // 0.0 to 1.0 (relative Y position)
    var color: String   // "blue", "green", "purple"
    var scale: CGFloat  // default is 1.0

    init(id: UUID = UUID(), x: CGFloat, y: CGFloat, color: String = "blue", scale: CGFloat = 1.0) {
        self.id = id
        self.x = x
        self.y = y
        self.color = color
        self.scale = scale
    }
}

struct Route: Identifiable, Codable {
    let id: UUID
    let wallID: UUID // tie the route to its wall
    var holds: [Hold]
    var name: String

    init(wallID: UUID, name: String = "Untitled Route", holds: [Hold] = []) {
        self.id = UUID()
        self.wallID = wallID
        self.name = name
        self.holds = holds
    }
}
