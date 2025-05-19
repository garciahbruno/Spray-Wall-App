import SwiftUI
import PhotosUI

struct Wall: Identifiable, Codable {
    let id: UUID
    var name: String
    var imageName: String
}

struct WallsListView: View {
    @StateObject private var viewModel = WallViewModel()
    @State private var showingAddWallSheet = false
    @State private var newWallName = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var selectedImageFilename: String?

    func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.selectedPhoto else { return }
                switch result {
                case .success(let data?):
                    if let uiImage = UIImage(data: data) {
                        let filename = UUID().uuidString + ".jpg"
                        let url = getImagePath(for: filename)
                        if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                            try? jpegData.write(to: url)
                            self.selectedImage = Image(uiImage: uiImage)
                            self.selectedImageFilename = filename
                        }
                    }
                case .success(nil):
                    print("No image data found.")
                case .failure(let error):
                    print("Image loading failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func getImagePath(for imageName: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(imageName)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea() // ✅ Adapts to dark/light mode

            VStack {
                Text("Walls")
                    .font(.title)
                    .fontWeight(.bold)

                List {
                    Section {
                        ForEach(viewModel.walls) { wall in
                            NavigationLink(destination: WallRoutes(wall: wall)) {
                                HStack {
                                    if let uiImage = UIImage(contentsOfFile: getImagePath(for: wall.imageName).path) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(12)
                                            .clipped()
                                            .drawingGroup() // helps reduce lag
                                    }

                                    Text(wall.name)
                                        .padding(.leading, 12)
                                        .foregroundColor(.primary)

                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: viewModel.deleteWall) // ✅ swipe-to-delete now works!
                    }
                }
                .listStyle(.plain) // optional but recommended for swipe support
                .scrollContentBackground(.hidden) // keeps your clean background

                .scrollContentBackground(.hidden) // ✅ Removes the gray in the list
                .background(Color.clear)

                Button("Add Wall") {
                    showingAddWallSheet = true
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddWallSheet) {
            VStack(spacing: 20) {
                Text("Add a New Wall")
                    .font(.title2)
                    .fontWeight(.semibold)

                VStack {
                    if let image = selectedImage {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(12)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue.opacity(0.8))

                            Text("Drop your image here, or")
                                .foregroundColor(.secondary)

                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Text("browse")
                                    .foregroundColor(.blue)
                                    .underline()
                            }

                            Text("Supports: JPG, JPEG2000, PNG")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                .foregroundColor(.gray.opacity(0.3))
                        )
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)

                TextField("Wall name", text: $newWallName)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                Button(action: {
                    if let image = selectedImage, !newWallName.isEmpty {
                        if let imageName = selectedImageFilename {
                            viewModel.addWall(name: newWallName, imageName: imageName)
                        }
                        newWallName = ""
                        selectedPhoto = nil
                        selectedImage = nil
                        showingAddWallSheet = false
                        selectedImageFilename = nil
                    }
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
            .background(Color(UIColor.systemGroupedBackground))
        }
        .onChange(of: selectedPhoto) { _, newItem in
            if let newItem {
                loadTransferable(from: newItem)
            }
        }
    }
}



#Preview {
    WallsListView()
}
