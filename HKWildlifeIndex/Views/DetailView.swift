//
//  DetailView.swift
//  HKWildlifeIndex
//
//  Created by Max Siebengartner on 6/4/2024.
//

import Foundation
import SwiftUI

struct DetailView : View {
    @State var entry : WildlifeEntry = WildlifeIndex().entries.first!
    @State var pos : CGFloat = 0
    @State var height : CGFloat = 0
    
    @State var showingInfo : Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                entry.thumbnail
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                VStack {
                    Spacer()
                    informationCard(geometry: geometry)
                        .offset(y: pos)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        pos = max(0, min(value.location.y, height - 110))
                                    }
                                }
                                .onEnded { value in
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        if abs(pos) < 30 {
                                            pos = 0
                                        } else if abs(pos) < 30 {
                                            pos = 0
                                        }
                                    }
                                }
                        )
                }
                .ignoresSafeArea()
            }
        }
    }
    func informationCard(geometry: GeometryProxy) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 55, height: 6)
                .padding(.top, 8)
                .foregroundStyle(Color(uiColor: .systemGray4))
            Text(entry.name)
                .padding(.horizontal)
                .foregroundStyle(.white)
                .font(.title)
                .frame(width: geometry.size.width, alignment: .leading)
                .bold()
                .padding(.top, 7)
            HStack {
                Text(entry.latin)
                
                    .foregroundStyle(.white)
                    .font(.title3)
                
                    .bold()
                Button {
                    showingInfo.toggle()
                } label: {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal)
            .frame(width: geometry.size.width, alignment: .leading)
            .padding(.bottom)
            Text(entry.description)
                .padding(.horizontal)
                .padding(.trailing)
                .padding(.bottom, 20)
                .foregroundStyle(.white)
        }
        .frame(width: geometry.size.width)
        .frame(minHeight: geometry.size.height * 0.66, alignment: .topLeading)
        .background(GeometryReader { geo in
            Color.clear
                .onAppear {
                    height = geo.size.height
                    pos = geometry.size.height / 2
                }
        })
        .background(VisualEffectView(effect: UIBlurEffect(style: .regular)))
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView()
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
#Preview {
    DetailView()
}
