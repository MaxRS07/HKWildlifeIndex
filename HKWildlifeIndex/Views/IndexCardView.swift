

import Foundation
import SwiftUI

struct IndexCardView : View {
    @State var entry : WildlifeEntry
    @State var discovered : Bool = true
    var body: some View {
        GeometryReader { geometry in
            VStack {
                entry.thumbnail
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5, alignment: .top)
                    .clipped()
                VStack {
                    Text(discovered ? entry.name : "???")
                        .foregroundStyle(.black)
                        .frame(width: geometry.size.width * 0.9, alignment: .topLeading)
                        .bold()
                    Text(discovered ? entry.latin : "???")
                        .frame(width: geometry.size.width * 0.9, alignment: .topLeading)
                        .foregroundStyle(Color(uiColor: .systemGray2))
                }
                .frame(height: geometry.size.height * 0.2, alignment: .topLeading)
                Text(entry.rarity.textView.name)
                    .padding(3)
                    .padding(.horizontal)
                    .background(entry.rarity.textView.color.brightness(entry.rarity.textView.background))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .frame(width: geometry.size.width * 0.9, alignment: .leading)
                    .foregroundStyle(entry.rarity.textView.color)
                    .padding(.bottom, 5)
                Spacer()
            }
            .frame(height: geometry.size.height)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 8)
        }

    }
}
#Preview {
    ScrollView(.horizontal) {
        HStack {
            ForEach(WildlifeIndex().entries, id: \.self) {entry in
                IndexCardView(entry: entry)
                    .frame(width: 165, height: 200)
                    .background(.blue)
            }
        }
        .padding()
    }
}
