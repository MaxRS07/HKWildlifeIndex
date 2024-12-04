
import Foundation
import SwiftUI

struct MarkerDetailView : View {
    @State var marker: WildlifeMarker
    var body: some View {
        GeometryReader { geometry in
            VStack {
                marker.type.thumbnail
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.3, alignment: .top)
                    .padding(.bottom, 70)
                    .clipped()
                Text(marker.type.name)
                    .font(.title2)
                    .bold()
                Text("Spotted on \(marker.date)")
                    .frame(width: geometry.size.width * 0.75, alignment: .leading)
                Text("Location: (" + marker.lat.description + ", " + marker.long.description + ")")
                    .frame(width: geometry.size.width * 0.75, alignment: .leading)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
        }
    }
}
#Preview {
    MarkerDetailView(marker: WildlifeMarkers[0])
}
