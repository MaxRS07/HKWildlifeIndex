//
//  MapView.swift
//  HKWildlifeIndex
//
//  Created by Max Siebengartner on 26/3/2024.
//

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
    @State var cameraBounds = MapCameraBounds(centerCoordinateBounds: MKCoordinateRegion(
        center: .hongKong,
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.25)
    ), minimumDistance: 1_000, maximumDistance: 150_000)
    
    @State private var mapCamPos: MapCameraPosition = .camera(MapCamera(
        centerCoordinate: .hongKong,
        distance: 125000
    ))
    
    var body: some View {
        Map(position: $mapCamPos, bounds: cameraBounds) {
            ForEach(WildlifeMarkers) { markerInfo in
                Marker(markerInfo.entryType.name, coordinate: markerInfo.position)
            }
        }
        .overlay(alignment: .bottom) {
            mapOverlay()
        }
    }
    func mapOverlay() -> some View {
        HStack {
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 1)) {
                    mapCamPos = .camera(MapCamera(
                        centerCoordinate: .hongKong,
                        distance: 125000
                    ))
                }
            } label: {
                Image(systemName: "house.fill")
                    .padding()
                    .background()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 8)
            }
            .padding()
        }
    }
}
#Preview {
    MapView()
}
