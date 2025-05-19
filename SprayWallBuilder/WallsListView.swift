//
//  WallsListView.swift
//  SprayWallBuilder
//
//  Created by Bruno Garcia on 5/14/25.
//

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
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(imageName)
    }
    

    
    
    var body: some View {
        VStack {
            Text("Walls")
                .font(.title)
                .fontWeight(.bold)
            List {
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
                            }

                            Text(wall.name)
                                .padding(.leading, 12)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: viewModel.deleteWall) // ✅ Add this
            }

            Button(action: {showingAddWallSheet = true},
                   label: {
                Text("Add Wall")
            })
            .sheet(isPresented: $showingAddWallSheet) {
                VStack(spacing: 20) {
                    Text("Enter Wall Name")
                        .font(.headline)

                    TextField("Wall name", text: $newWallName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    PhotosPicker(selection: $selectedPhoto,
                                 matching: .images) {
                        Text("Select Wall Photo")
                    }

                    Button("Save") {
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
                    }
                    .padding()
                }
                .padding()
            }
            .onChange(of: selectedPhoto) { oldItem, newItem in
                if let newItem {
                    loadTransferable(from: newItem)
                }
            }
            
        }
        
    }
}


#Preview {
    WallsListView()
}
