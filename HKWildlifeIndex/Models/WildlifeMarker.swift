//
//  WildlifeMarker.swift
//  HKWildlifeIndex
//
//  Created by Max Siebengartner on 27/3/2024.
//

import Foundation
import CoreLocation

public struct WildlifeMarker : Identifiable {
    public var id : String?
    let entryType : WildlifeEntry
    let position : CLLocationCoordinate2D
    
    init(entryType: WildlifeEntry, position: CLLocationCoordinate2D) {
        self.entryType = entryType
        self.position = position
    }
}
public let WildlifeMarkers = [
    WildlifeMarker(entryType: WildlifeIndex().entries[0], position: .hongKong),
]
