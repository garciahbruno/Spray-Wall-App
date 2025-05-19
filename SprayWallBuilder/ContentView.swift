//
//  ContentView.swift
//  SprayWallBuilder
//
//  Created by Bruno Garcia on 5/12/25.
//
import AVKit
import SwiftUI

let backgroundImage = Image("baseSprayWall")

struct ContentView: View {
    @State private var showWallsList = false
    var body: some View {
        
        
        NavigationStack {
            ZStack {
                backgroundImage
                    .blur(radius: 10)
                
                
                Button(action: {
                    showWallsList = true
                }, label: {
                    Text("My Walls")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding()
                })
                    
                    
                
                .navigationDestination(isPresented: $showWallsList) {
                    WallsListView()
                }
            }
        }
    
    }
}

#Preview {
    ContentView()
}
