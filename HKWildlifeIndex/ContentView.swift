//
//  ContentView.swift
//  HKWildlifeIndex
//
//  Created by Max Siebengartner on 23/3/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State var selection : Int = 0
    var body: some View {
        TabView(selection: $selection) {
            ScanSelectionView().tabItem { Label("Scan", systemImage: "camera.fill") }.tag(3)
            
            EntriesListView().tabItem { Label("Index", systemImage: "building.columns") }.tag(1)
            
            MapView().tabItem { Label("Map", systemImage: "map.fill") }.tag(2)
        }
    }
}

#Preview {
    ContentView()
}
