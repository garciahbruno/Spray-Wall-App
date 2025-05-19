// RouteBuilderView.swift (fixed long press delete + drag gesture conflict)

import SwiftUI

struct RouteBuilderView: View {
    let wallID: UUID
    let wallImage: UIImage
    let onSave: (Route) -> Void
    @State private var showingAddRouteForm = false
    @State private var routeName: String = ""
    @State private var holds: [Hold] = []
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                let imageSize = geo.size

                Image(uiImage: wallImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize.width, height: imageSize.height)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let location = value.location
                                let frame = geo.frame(in: .local)
                                let relX = (location.x - frame.minX) / frame.width
                                let relY = (location.y - frame.minY) / frame.height

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

                VStack {
                    Spacer()
                    Button(action: {
                        showingAddRouteForm = true
                    }) {
                        Text("Next")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $showingAddRouteForm) {
            VStack(spacing: 20) {
                Text("Add a Route")
                    .font(.title3)
                    .fontWeight(.semibold)

                TextField("Route name", text: $routeName)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                Button(action: {
                    let route = Route(
                        wallID: wallID,
                        name: routeName.isEmpty ? "Untitled Route" : routeName,
                        holds: holds
                    )
                    onSave(route)
                    dismiss()
                }) {
                    Text("Save")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .presentationDetents([.height(250)])
        }
    }
}

struct HoldCircle: View {
    var hold: Hold
    var imageSize: CGSize
    var onUpdate: (Hold) -> Void
    var onDelete: () -> Void

    @GestureState private var pinchScale: CGFloat = 1.0

    var body: some View {
        let combinedScale = hold.scale * pinchScale

        Circle()
            .strokeBorder(color(for: hold.color), lineWidth: 3)
            .background(Circle().fill(Color.white.opacity(0.001)))
            .frame(width: 36, height: 36)
            .scaleEffect(combinedScale)
            .position(x: hold.x * imageSize.width, y: hold.y * imageSize.height)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        var moved = hold
                        moved.x = min(max(0, value.location.x / imageSize.width), 1)
                        moved.y = min(max(0, value.location.y / imageSize.height), 1)
                        onUpdate(moved)
                    }
            )
            .highPriorityGesture(
                MagnificationGesture()
                    .updating($pinchScale) { current, state, _ in
                        state = current
                    }
                    .onEnded { scaleAmount in
                        var resized = hold
                        resized.scale = max(0.5, min(2.0, hold.scale * scaleAmount))
                        onUpdate(resized)
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
