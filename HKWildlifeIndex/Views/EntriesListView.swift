//
//  EntriesListView.swift
//  HKWildlifeIndex
//
//  Created by Max Siebengartner on 27/3/2024.
//

import Foundation
import SwiftUI

enum SortFilter : CaseIterable {
    case Alphabetical
    case Rarity
}
struct EntriesListView : View {
    
    @State var listStyle : Int = 1
    @State var sortMode : Int = 0
    @State var ascending : Bool = false
    @State var forceID : String = UUID().uuidString
    
    @State var searching : Bool = false
    @State var query : String = ""
    
    @State var index = WildlifeIndex()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    Text("Wildlife Entries")
                        .font(.title)
                        .bold()
                    
                    topBar()
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.15, alignment: .center)
                
                if listStyle == 0 {
                    wildlifeList()
                        .id(forceID)
                } else {
                    wildlifeGallery()
                        .id(forceID)
                }
            }
        }
        .onChange(of: query) {
            sortList(query: query)
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
    }
    func sortList(query: String = "") -> [WildlifeEntry] {
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
            forceID = UUID().uuidString
            return index.entries
        } else {
            index.entries = index.entries.filter({
                $0.name.localizedCaseInsensitiveContains(query)
            })
            forceID = UUID().uuidString
            return index.entries
        }
    }
    func topBar() -> some View {
        return GeometryReader { geometry in
            HStack {
                if !searching {
                    Picker("Sort By", selection: $sortMode) {
                        Text("Alphabetical").tag(0)
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
        List {
            ForEach(index.entries) { entry in
                GeometryReader { geometry in
                    NavigationLink {
                    } label: {
                        HStack {
                            entry.thumbnail
                                .resizable()
                                .frame(width: geometry.size.width * 0.33, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .clipped()
                                .padding(.trailing)
                            VStack {
                                Text(entry.name)
                                    .frame(width: geometry.size.width, alignment: .leading)
                                    .bold()
                                Text(entry.latin)
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
                .padding(.vertical, 35)
                
            }
        }
        .ignoresSafeArea()
    }
    func wildlifeGallery() -> some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                ForEach(0..<Int(ceil(Double(index.entries.count)/2.0))) { i in
                    HStack {
                        ForEach(0..<2) { j in
                            if 2 * i + j < index.entries.count {
                                NavigationLink {
                                    
                                } label: {
                                    IndexCardView(entry: index.entries[2 * i + j])
                                        
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
            }
        }
    }
}
#Preview {
    EntriesListView()
}
