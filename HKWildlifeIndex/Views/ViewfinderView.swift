//
//  CameraOutputView.swift
//  HKWildlifeIndex
//
//  Created by Max Siebengartner on 26/3/2024.
//

import Foundation
import SwiftUI

struct ViewfinderView : View {
    @Binding var image : Image?
    var body: some View {
        GeometryReader { geo in
            image?
                .resizable()
                .frame(width: geo.size.width, height: geo.size.height)
                .scaledToFill()
        }
    }
}
