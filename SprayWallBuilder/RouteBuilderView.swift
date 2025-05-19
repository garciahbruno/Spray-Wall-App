// RouteBuilderView.swift (fully working with DragGesture for tap + location)

import SwiftUI

struct RouteBuilderView: View {
    let wallID: UUID
    let wallImage: UIImage
    let onSave: (Route) -> Void

    @State private var holds: [Hold] = []
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geo in
            let imageSize = geo.size

            ZStack(alignment: .bottom) {
                Color.clear.overlay(
                    Image(uiImage: wallImage)
                        .resizable()
                        .scaledToFit()
                        .contentShape(Rectangle())
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            let tapLocation = value.location
                            let imageFrame = geo.frame(in: .local)
                            let relX = (tapLocation.x - imageFrame.minX) / imageFrame.width
                            let relY = (tapLocation.y - imageFrame.minY) / imageFrame.height

                            let threshold: CGFloat = 0.04
                            if !holds.contains(where: { abs($0.x - relX) < threshold && abs($0.y - relY) < threshold }) {
                                holds.append(Hold(x: relX, y: relY))
                            }
                        }
                )

                ForEach(holds) { hold in
                    HoldCircle(hold: hold, imageSize: imageSize) { updated in
                        if let index = holds.firstIndex(where: { $0.id == hold.id }) {
                            holds[index] = updated
                        }
                    } onDelete: {
                        holds.removeAll { $0.id == hold.id }
                    }
                }

                Button("Save Route") {
                    let route = Route(wallID: wallID, holds: holds)
                    onSave(route)
                    dismiss()
                }
                .padding()
            }
        }
    }
}

struct HoldCircle: View {
    var hold: Hold
    var imageSize: CGSize
    var onUpdate: (Hold) -> Void
    var onDelete: () -> Void

    @State private var offset: CGSize = .zero

    var body: some View {
        Circle()
            .strokeBorder(color(for: hold.color), lineWidth: 3)
            .background(Circle().fill(Color.white.opacity(0.001)))
            .frame(width: 36, height: 36)
            .position(x: hold.x * imageSize.width, y: hold.y * imageSize.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newX = min(max(0, value.location.x / imageSize.width), 1)
                        let newY = min(max(0, value.location.y / imageSize.height), 1)
                        var moved = hold
                        moved.x = newX
                        moved.y = newY
                        onUpdate(moved)
                    }
            )
            .onTapGesture {
                var changed = hold
                changed.color = nextColor(from: hold.color)
                onUpdate(changed)
            }
            .onLongPressGesture {
                onDelete()
            }
    }

    func color(for name: String) -> Color {
        switch name {
        case "green": return .green
        case "purple": return .purple
        default: return .blue
        }
    }

    func nextColor(from current: String) -> String {
        switch current {
        case "blue": return "green"
        case "green": return "purple"
        default: return "blue"
        }
    }
}

#Preview {
    RouteBuilderView(wallID: UUID(), wallImage: UIImage(systemName: "photo")!) { _ in }
}
