// WallRoutes.swift (fully updated with swipe-to-delete and cleaner UI)

import SwiftUI

struct WallRoutes: View {
    let wall: Wall
    @State private var routes: [Route] = []
    @State private var showingBuilder = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea() // Clean background

            VStack {
                Text("Routes")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)

                List {
                    ForEach(routes) { route in
                        NavigationLink(destination: RouteDetailView(
                            wallImage: UIImage(contentsOfFile: getImagePath(for: wall.imageName).path)!,
                            route: route
                        )) {
                            Text(route.name)
                        }
                    }
                    .onDelete { indexSet in
                        routes.remove(atOffsets: indexSet)
                        RouteStorage.save(routes, for: wall.id)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)

                Button("Add Route") {
                    showingBuilder = true
                }
                .padding()
            }
        }
        .onAppear {
            routes = RouteStorage.load(for: wall.id)
        }
        .sheet(isPresented: $showingBuilder) {
            if let image = UIImage(contentsOfFile: getImagePath(for: wall.imageName).path) {
                RouteBuilderView(wallID: wall.id, wallImage: image) { newRoute in
                    routes.append(newRoute)
                    RouteStorage.save(routes, for: wall.id)
                }
            } else {
                Text("Failed to load wall image")
            }
        }
    }

    func getImagePath(for imageName: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(imageName)
    }
}

#Preview {
    WallRoutes(wall: Wall(id: UUID(), name: "Test", imageName: "test.jpg"))
}
