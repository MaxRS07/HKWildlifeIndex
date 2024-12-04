import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State var selection : Int = 1
    var body: some View {
        TabView(selection: $selection) {
            EntriesListView().tabItem { Label("Index", systemImage: "building.columns") }.tag(1)
            
            MapView().tabItem { Label("Map", systemImage: "map.fill") }.tag(2)
            
            ProfileView().tabItem { Label("Profile", systemImage: "person.fill") }.tag(3)
        }
    }
}

#Preview {
    ContentView()
}
