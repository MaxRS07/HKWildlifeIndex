

import Foundation
import SwiftUI

struct ProfileView : View {
    @EnvironmentObject var userManager : UserManager
    @State var loginPresented : Bool = false
    var body: some View {
        GeometryReader { geometry in
            UserDetailView(loginPresented: $loginPresented)
            .sheet(isPresented: $loginPresented) {
                LoginView(active: $loginPresented)
                    .presentationDetents([.height(330)])
            }
        }
        .onAppear {
        }
    }
}
struct UserDetailView : View {
    @EnvironmentObject var userManager : UserManager
    @State var guestInfo : Bool = false
    @Binding var loginPresented: Bool

    @State var selectedView : Int = 1
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    VStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .foregroundStyle(.gray)
                            .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25)
                            .padding(.horizontal, 25)
                            .padding(.top)
                        HStack {
                            Text(userManager.currentUser.username)
                                .padding(.leading, 20)
                                .font(.title3)
                                .minimumScaleFactor(0.5)
                            if !userManager.loggedIn {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        guestInfo.toggle()
                                    }
                                } label: {
                                    Image(systemName: "info.circle")
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                    VStack {
                        HStack {
                            VStack {
                                Text(userManager.currentUser.discovered.count.description)
                                Text("entries")
                            }
                            .padding(.horizontal)
                        }
                        
                    }
                    .frame(width: geometry.size.width * 0.5, alignment: .leading)
                    .padding(.top)
                }
                
                Picker("", selection: $selectedView) {
                    Image(systemName: "square.grid.2x2").tag(1)
                    Image(systemName: "chart.pie").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if selectedView == 1 {
                    if userManager.localUser.discovered.count > 0 {
                        ImageListView()
                    } else {
                        Spacer()
                        Text("You have no entries")
                            .font(.title)
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                } else {
                    StatsView()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .overlay(alignment: .top) {
                if guestInfo {
                    HStack(spacing: 0) {
                        Button {
                            loginPresented = true
                            guestInfo = false
                        } label: {
                            Text("Login")
                        }
                        Text(" to access online features")
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 8)
                    .padding(.top, geometry.size.height * 0.2)
                }
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                guestInfo = false
            }
        }
    }
}
struct ImageListView : View {
    @EnvironmentObject var userManager : UserManager
    @State var id : UUID = UUID()
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ForEach(0..<specialNumber()) { i in
                    HStack {
                        ForEach(0..<3) { j in
                            if userManager.currentUser.photos.count < 3 * i + j {
                                Image(uiImage: .init(data: userManager.currentUser.photos[3 * i + j - 1])!)
                            } else {
                                
                            }
                        }
                    }
                }
                .id(userManager.forceID)
            }
        }
    }
    func specialNumber() -> Int {
        return Int(ceil(Double(userManager.localUser.photos.count)/3.0))
    }
}
struct StatsView : View {
    @EnvironmentObject var userManager : UserManager
    @State var entriesList : [WildlifeEntry] = []
    @State var percent : Double = 0.0
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Found \(percent)%")
                    .font(.title3)
                    .bold()
                    .padding(.bottom)
                ForEach(Rarity.allCases, id: \.self) { i in
                    Text(i.textView.name + " (\(filterRarity(entriesList, i).count)/\(filterRarity(WildlifeIndex().entries, i).count))")
                        .bold()
                    ProgressView(value: Double(filterRarity(entriesList, i).count)/Double(filterRarity(WildlifeIndex().entries, i).count))
                        .padding(.horizontal, 60)
                        .tint(i.textView.color)
                        .padding(.bottom)
                }
                .id(userManager.forceID)
            }
            .padding(.vertical)
            .background()
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(radius: 8)
            .padding()
            .onChange(of: userManager.forceID) {
                refreshData()
            }
        }
    }
    func discoveredCard() -> some View {
        return VStack {
            
        }
    }
    func refreshData() {
        entriesList = WildlifeIndex().entries.filter { userManager.localUser.discovered.contains($0.name)
        }
        percent = Double(entriesList.count)/Double(WildlifeIndex().entries.count) * 100
    }
    func filterRarity(_ entries: [WildlifeEntry], _ rarity: Rarity) -> [WildlifeEntry] {
        var filtered : [WildlifeEntry] = []
        for entry in entries {
            if entry.rarity == rarity {
                filtered.append(entry)
            }
        }
        return filtered
    }
}
