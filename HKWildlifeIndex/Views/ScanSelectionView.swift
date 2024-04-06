//
//  ScanSelectionView.swift
//  HKWildlifeIndex
//
//  Created by Max Siebengartner on 25/3/2024.
//

import Foundation
import SwiftUI

struct ScanSelectionView : View {
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                HStack {
                    NavigationLink {
                        CameraView()
                    } label: {
                        Image(systemName: "camera")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width * 0.2)
                    }
                    .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 10)
                    .padding()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: geometry.size.width * 0.2)
                    }
                    .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 10)
                    .padding()
                }
            }
        }
    }
}
struct ScanButton : View {
    @State var color : UIColor
    var body: some View {
        VStack {
            Image(systemName: "leaf.fill")
                .resizable()
                .frame(width: 45, height: 45)
                .foregroundStyle(.white)
        }
        .frame(width: 150, height: 150)
        .background(LinearGradient(colors: [Color(uiColor: color), Color(uiColor: color * 0.75)], startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 8)
    }
}
extension UIColor {
    static func *(lhs: UIColor, rhs: CGFloat) -> UIColor {
        var red : CGFloat = 0.0, green : CGFloat = 0.0, blue : CGFloat = 0.0, a : CGFloat = 0.0
        lhs.getRed(&red, green: &green, blue: &blue, alpha: &a)
        return UIColor(red: red * rhs, green: green * rhs, blue: blue * rhs, alpha: a)
    }
}
