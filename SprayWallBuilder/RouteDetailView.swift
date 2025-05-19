//
//  RouteDetailView.swift
//  SprayWallBuilder
//
//  Created by Bruno Garcia on 5/19/25.
//

import Foundation
// RouteDetailView.swift

import SwiftUI

struct RouteDetailView: View {
    let wallImage: UIImage
    let route: Route

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(uiImage: wallImage)
                    .resizable()
                    .scaledToFit()

                ForEach(route.holds) { hold in
                    Circle()
                        .strokeBorder(color(for: hold.color), lineWidth: 2)
                        .background(Circle().fill(Color.clear))
                        .frame(width: 30, height: 30)
                        .position(
                            x: hold.x * geo.size.width,
                            y: hold.y * geo.size.height
                        )
                }
            }
            .navigationTitle(route.name)
        }
    }

    func color(for name: String) -> Color {
        switch name {
        case "green": return .green
        case "purple": return .purple
        default: return .blue
        }
    }
}

#Preview {
    RouteDetailView(
        wallImage: UIImage(systemName: "photo")!,
        route: Route(wallID: UUID(), name: "Test", holds: [Hold(x: 0.5, y: 0.5)])
    )
}
