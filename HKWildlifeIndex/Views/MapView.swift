import Foundation
import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static let hongKong: Self = .init(
        latitude: 22.3193,
        longitude: 114.1694
    )
}
        
struct MapView : View {
    @State private var markers: [WildlifeMarker] = []
    @State private var showsFilters : Bool = false
    @State private var rarityFilter: [Rarity] = []
    
    @State var cameraBounds = MapCameraBounds(centerCoordinateBounds: MKCoordinateRegion(
        center: .hongKong,
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.25)
    ), minimumDistance: 1_000, maximumDistance: 150_000)
    
    @State private var mapCamPos: MapCameraPosition = .camera(MapCamera(
        centerCoordinate: .hongKong,
        distance: 125000
    ))
    
    @State private var selectedMarker : WildlifeMarker?
    
    var body: some View {
        Map(position: $mapCamPos, bounds: cameraBounds, selection: $selectedMarker) {
            ForEach(markers) { markerInfo in
                if rarityFilter.contains(markerInfo.type.rarity) || rarityFilter.isEmpty {
                    Marker(coordinate: markerInfo.position) {
                        Label(markerInfo.entryType, systemImage: markerInfo.type.symbol + ".fill")
                    }
                    .tag(markerInfo)
                    .tint(markerInfo.type.rarity.textView.color)
                }
            }
        }
        .task {
            markers = await MapManager().getMarkers()
        }
        .overlay(alignment: .bottom) {
            mapOverlay()
        }
        .sheet(item: $selectedMarker) { selectedPlacemark in
            MarkerDetailView(marker: selectedPlacemark)
            .presentationDetents([.height(350)])
        }
    }
    func mapOverlay() -> some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    Button {
                        withAnimation(.easeInOut) {
                            showsFilters.toggle()
                        }
                    } label: {
                        Image(systemName: "binoculars.fill")
                            .frame(width: geometry.size.width * 0.125, height: geometry.size.width * 0.125)
                            .background()
                            .clipShape(Circle())
                            .shadow(radius: 8)
                    }
                    .frame(width: geometry.size.width * 0.13, height: geometry.size.width * (showsFilters ? 0.5 : 0.125), alignment: .bottom)
                    .background()
                    .overlay(alignment: .top) {
                        if showsFilters {
                            VStack() {
                                ForEach(Rarity.allCases, id: \.self) { rarity in
                                    Button {
                                        if !rarityFilter.contains(rarity) {
                                            rarityFilter.append(rarity)
                                        } else {
                                            rarityFilter.removeFirst(where: {$0 == rarity})
                                        }
                                    } label: {
                                        Image(systemName: "leaf" + (rarityFilter.contains(rarity) ? ".fill" : ""))
                                            .frame(width: geometry.size.width * 0.05, height: geometry.size.width * 0.05)
                                            .foregroundStyle(rarity.textView.color)
                                        
                                    }
                                }
                            }
                            .padding(.top, geometry.size.width * 0.025)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .padding(.vertical, 5)
                    Button {
                        withAnimation(.easeInOut) {
                            mapCamPos = .camera(MapCamera(
                                centerCoordinate: .hongKong,
                                distance: 125000
                            ))
                        }
                    } label: {
                        Image(systemName: "house.fill")
                            .frame(width: geometry.size.width * 0.125, height: geometry.size.width * 0.125)
                            .background()
                            .clipShape(Circle())
                            .shadow(radius: 8)
                            .foregroundStyle(mapCamPos == .camera(MapCamera(
                                centerCoordinate: .hongKong,
                                distance: 125000
                            )) ? .gray : .blue)
                    }
                    .frame(width: geometry.size.width * 0.125, height: geometry.size.width * 0.125, alignment: .bottom)
                }
                .padding([.horizontal, .bottom])
                .frame(height: geometry.size.height, alignment: .bottom)
            }
            .frame(width: geometry.size.width, alignment: .trailing)
        }
    }
}
#Preview {
    MapView()
}
