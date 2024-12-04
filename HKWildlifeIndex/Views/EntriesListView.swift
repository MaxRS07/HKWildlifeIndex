
import Foundation
import SwiftUI
import Photos
import PhotosUI
import os.log

enum SortFilter : CaseIterable {
    case Alphabetical
    case Rarity
}
struct EntriesListView : View {
    @EnvironmentObject var userManager : UserManager
    @State private var photoItem: PhotosPickerItem?
    @State private var uiimage: UIImage?
    @State var listStyle : Int = 1
    @State var sortMode : Int = 0
    @State var ascending : Bool = false
    
    @State var searching : Bool = false
    @State var query : String = ""
    
    @State var discovered: [WildlifeEntry] = []
    @State var undiscovered: [WildlifeEntry] = []
    
    @State var index = WildlifeIndex()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    HStack {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .frame(width: 22, height: 29)
                                .foregroundStyle(.blue)
                        }
                        .navigationDestination(item: $uiimage) { item in
                            ImageScanView(image: item)
                        }
                        Text("Wildlife Entries")
                            .font(.title)
                            .bold()
                            .padding(.horizontal, 40)
                        NavigationLink {
                            CameraView()
                        } label: {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .frame(width: 26, height: 21)
                                .foregroundStyle(.blue)
                        }
                    }
                    topBar()
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.15, alignment: .center)
                
                if listStyle == 0 {
                    wildlifeList()
                        .id(userManager.forceID)
                        .padding(.top)
                } else {
                    wildlifeGallery()
                        .id(userManager.forceID)
                }
            }.tint(.white)
        }
        .onChange(of: query) {
            sortList()
        }
        .onChange(of: ascending) {
            sortList()
        }
        .onChange(of: sortMode) {
            sortList()
        }
        .onAppear {
            sortList()
        }
        .onChange(of: photoItem) {
            Task {
                if let photoItem {
                    do {
                        if let data = try await photoItem.loadTransferable(type: Data.self) {
                            uiimage = .init(data: data) ?? nil
                        }
                    } catch {
                        Logger().error("\(error.localizedDescription)")
                    }
                }
            }
        }
        .onAppear {
           refresh()
        }
        .onChange(of: userManager.forceID) {
            refresh()
        }
    }
    func refresh() {
        discovered = index.entries.filter({userManager.currentUser.discovered.contains($0.name)})
        undiscovered = index.entries.filter({!userManager.currentUser.discovered.contains($0.name)})
    }
    func sortList() {
        let filter = SortFilter.allCases[sortMode]
        index.entries = WildlifeIndex().entries
        if query.isEmpty {
            index.entries.sort(by: {
                switch filter {
                case .Alphabetical:
                    $0.name < $1.name
                case .Rarity:
                    Rarity.allCases.firstIndex(of: $0.rarity)! > Rarity.allCases.firstIndex(of: $1.rarity)!
                }
            })
            if ascending {
                index.entries.reverse()
            }
        } else {
            index.entries = index.entries.filter({
                $0.name.localizedCaseInsensitiveContains(query)
            })
        }
        userManager.refresh()
    }
    func topBar() -> some View {
        return GeometryReader { geometry in
            HStack {
                if !searching {
                    Picker("Sort By", selection: $sortMode) {
                        Text("Name").tag(0)
                        Text("Rarity").tag(1)
                        Text("Date Found").tag(2)
                    }
                    .colorMultiply(.black)
                    .frame(width: geometry.size.width * 0.35)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    Button {
                        ascending.toggle()
                    } label: {
                        Image(systemName: "chevron." + (ascending ? "up" : "down"))
                    }
                    .colorMultiply(.black)
                    .frame(width: geometry.size.width * 0.08)
                    .padding(.vertical, 11.8)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    Picker("", selection: $listStyle) {
                        Image(systemName: "list.bullet").tag(0)
                            .frame(height: geometry.size.height * 0.1)
                        Image(systemName: "square.grid.2x2").tag(1)
                            .frame(height: geometry.size.height * 0.1)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: geometry.size.width * 0.25)
                    .scaledToFit()
                    .scaleEffect(CGSize(width: 1.125, height: 1.125))
                    .padding(.horizontal)
                    Button {
                        withAnimation(.easeInOut) {
                            searching = true
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                            .foregroundStyle(.black)
                    }
                }
                if searching {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color(uiColor: .systemGray2))
                        TextField("Search", text: $query)
                        Button {
                            query = ""
                            withAnimation(.easeInOut) {
                                searching = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(Color(uiColor: .systemGray2))
                        }
                    }
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.55)
                    .padding(.horizontal)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .frame(maxWidth: geometry.size.width, alignment: .center)
        }
    }
    func wildlifeList() -> some View {
        return GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(discovered, id: \.self) { entry in
                        NavigationLink {
                            DetailView(entry: entry)
                        } label: {
                            wildlifeListCard(entry: entry, true)
                        }
                        .padding(.horizontal)
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height/8, alignment: .center)
                        .padding(.vertical)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 4)
                    }
                    .padding()
                    
                    Group {
                        Text("Undiscovered")
                            .font(.title2)
                            .bold()
                        Divider()
                    }
                    .frame(width: geometry.size.width * 0.9, alignment: .center)
                    ForEach(undiscovered, id: \.self) { entry in
                        wildlifeListCard(entry: entry, false)
                            .padding(.horizontal)
                            .frame(width: geometry.size.width * 0.9, alignment: .center)
                            .padding(.vertical, 50)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
    }
    func wildlifeListCard(entry: WildlifeEntry, _ found:Bool) -> some View {
        GeometryReader { geometry in
            HStack {
                entry.thumbnail
                    .resizable()
                    .frame(width: geometry.size.width * 0.33, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .clipped()
                    .padding(.trailing)
                VStack {
                    Text(found ? entry.name : "???")
                        .frame(width: geometry.size.width, alignment: .leading)
                        .foregroundStyle(.black)
                        .bold()
                    Text(found ? entry.latin : "???")
                        .frame(width: geometry.size.width, alignment: .leading)
                        .foregroundStyle(Color(uiColor: .systemGray2))
                    Text(entry.rarity.textView.name)
                        .padding(3)
                        .padding(.horizontal)
                        .background(entry.rarity.textView.color.brightness(entry.rarity.textView.background))
                    
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .frame(width: geometry.size.width, alignment: .leading)
                        .foregroundStyle(entry.rarity.textView.color)
                }
            }
            .frame(height: geometry.size.height)
        }
    }
    func wildlifeGallery() -> some View {
        return GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(0..<Int(ceil(Double(discovered.count)/2.0))) { i in
                        HStack {
                            ForEach(0..<2) { j in
                                if 2 * i + j < discovered.count {
                                    NavigationLink {
                                        DetailView(entry: discovered[2 * i + j])
                                    } label: {
                                        IndexCardView(entry: discovered[2 * i + j], discovered: true)
                                        
                                    }
                                    .frame(width: 165, height: 200)
                                    .padding(8)
                                } else {
                                    VStack {}.frame(width: 165).padding(8)
                                }
                            }
                        }
                        .frame(width: geometry.size.width, alignment: .center)
                    }
                    Group {
                        Text("Undiscovered")
                            .font(.title2)
                            .bold()
                        Divider()
                    }
                    .frame(width: geometry.size.width * 0.9, alignment: .center)
                    ForEach(0..<Int(ceil(Double(undiscovered.count)/2.0))) { i in
                        HStack {
                            ForEach(0..<2) { j in
                                if 2 * i + j < undiscovered.count {
                                    IndexCardView(entry: undiscovered[2 * i + j], discovered: false)
                                        .frame(width: 165, height: 200)
                                        .padding(8)
                                } else {
                                    VStack {}.frame(width: 165).padding(8)
                                }
                            }
                        }
                        .frame(width: geometry.size.width, alignment: .center)
                    }
                }
            }
        }
    }
}
#Preview {
    EntriesListView()
}
