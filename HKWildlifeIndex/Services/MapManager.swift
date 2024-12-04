import Foundation
import FirebaseCore
import FirebaseFirestore
import os.log

class MapManager {
    func getMarkers() async -> [WildlifeMarker] {
        let markersDB = Firestore.firestore().collection("markers")
        do {
            let query = try await markersDB.getDocuments()
            let markers = try query.documents.map({
                try $0.data(as: WildlifeMarker.self)
            })
            return markers
        } catch {
            Logger().error("\(error.localizedDescription)")
        }
        return []
    }
    func addMarker(_ marker: WildlifeMarker) {
        let markersDB = Firestore.firestore().collection("markers")
        if let markerJson = jsonEncode(marker) {
            markersDB.addDocument(data: markerJson)
        }
    }
}
