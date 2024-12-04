

import Foundation
import SwiftUI

struct ViewfinderView : View {
    @Binding var image : Image?
    var body: some View {
        GeometryReader { geo in
            image?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(.degrees(90))
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
