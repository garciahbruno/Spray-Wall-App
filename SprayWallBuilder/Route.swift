
import Foundation
import SwiftUI

struct Hold: Identifiable, Codable, Equatable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var color: String

    init(id: UUID = UUID(), x: CGFloat, y: CGFloat, color: String = "blue") {
        self.id = id
        self.x = x
        self.y = y
        self.color = color
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
