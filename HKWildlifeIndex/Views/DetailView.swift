
import Foundation
import SwiftUI

struct DetailView : View {
    @Environment(\.presentationMode) var presentationMode
    @State var entry : WildlifeEntry
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
                                        if abs(pos) < 50 {
                                            pos = 0
                                        }
                                    }
                                }
                        )
                        
                        
                }
                .ignoresSafeArea()
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    func informationCard(geometry: GeometryProxy) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 55, height: 6)
                .padding(.top, 8)
                .foregroundStyle(Color(uiColor: .systemGray4))
            Text(entry.name)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.horizontal)
                .foregroundStyle(.white)
                .font(.title)
                .frame(width: geometry.size.width, alignment: .leading)
                .bold()
                .padding(.top, 7)
            HStack {
                Text(entry.latin)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                    .font(.title3)
                    .bold()
                Button {
                    withAnimation(.easeInOut) {
                        if pos > height - 330 {
                            pos = height - 330
                        }
                    }
                    withAnimation(.easeInOut(duration: 0.1)) {
                        showingInfo.toggle()
                    }
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
        .overlay(alignment: .top) {
            if showingInfo {
                VStack {
                    VStack {
                        ForEach(0..<8, id: \.self) { i in
                            HStack {
                                Text(Classification.hierarchy[i] + ":")
                                    .padding(.leading)
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(entry.classification.list[i].capitalized)
                                    .padding(.trailing)
                                    .foregroundStyle(.white)
                            }
                            
                        }
                    }
                    .padding(.vertical)
                    .frame(width: geometry.size.width * 0.6)
                    .background(VisualEffectView(effect: UIBlurEffect(style: .dark)))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 100)
                }
            }
        }
        .frame(width: geometry.size.width)
        .frame(minHeight: geometry.size.height * 0.66, alignment: .topLeading)
        .background(GeometryReader { geo in
            Color.clear
                .onAppear {
                    height = geo.size.height
                    pos = height/2
                }
        })
        .background(VisualEffectView(effect: UIBlurEffect(style: .regular)))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .gesture(TapGesture().onEnded {
            withAnimation(.easeInOut(duration: 0.1)) {
                showingInfo = false
            }
        })
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
    DetailView(entry: WildlifeIndex().entries[0])
}
