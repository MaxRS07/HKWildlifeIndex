
import Foundation
import CoreLocation
import SwiftData


public struct WildlifeMarker : Hashable, Identifiable, Codable {
    public static func == (lhs: WildlifeMarker, rhs: WildlifeMarker) -> Bool {
        return false//lhs.entryType == rhs.entryType
    }
    public let id: String = UUID().uuidString
    let entryType : String
    let date: String
    let lat: Double
    let long: Double
    
    init(entryType: WildlifeEntry, position: CLLocationCoordinate2D, date: Date) {
        self.entryType = entryType.name
        self.lat = position.latitude
        self.long = position.longitude
        self.date = date.formatted(date: .abbreviated, time: .shortened)
    }
    init(entryType: WildlifeEntry, latitude: Double, longitude: Double, date: Date) {
        self.entryType = entryType.name
        self.lat = latitude
        self.long = longitude
        self.date = date.formatted(date: .abbreviated, time: .shortened)
    }
    public var position: CLLocationCoordinate2D {
        return .init(latitude: lat, longitude: long)
    }
    public var type : WildlifeEntry {
        return WildlifeIndex().entries.first(where: {$0.name == self.entryType})!
    }
}
public let WildlifeMarkers : [WildlifeMarker] = [
    WildlifeMarker(entryType: WildlifeIndex().entries[0], position: .hongKong, date: .now),
]
