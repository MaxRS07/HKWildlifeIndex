
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


import Foundation
import SwiftUI
import UIKit
import GoogleSignInSwift
import GoogleSignIn
import os.log

//sheet view
struct LoginView : View {
    @State var animation : Bool = false
    @State var username : String = ""
    @State var password : String = ""
    @State var errorMessage : String = ""
    @State var authActive : Bool  = false
    @State var showingPrompt : Bool = false
    
    @Binding var active : Bool
    
    @EnvironmentObject var userManager : UserManager
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    Text("Login")
                        .frame(width: geometry.size.width)
                        .font(.title)
                        .bold()
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .green], startPoint: .leading, endPoint: .trailing)
                        )
                        .onAppear {
                            withAnimation(.easeInOut) {
                                animation = true
                            }
                        }
                    TextField("Username", text: $username)
                        .frame(width: geometry.size.width * 0.8, alignment: .center)
                        .padding()
                        .background(Color(uiColor: .systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 5)
                    SecureField("Password", text: $password)
                        .frame(width: geometry.size.width * 0.8, alignment: .center)
                        .padding()
                        .background(Color(uiColor: .systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom)
                        .clipped()
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
 
                    Button {
                        Task {
                            do {
                                try await userManager.signIn(username: username, password: password)
                            } catch {
                                errorMessage = errorMessage.description
                            }
                        }
                    } label: {
                        Text("Login")
                            .foregroundStyle(.blue)
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.12)
                            .overlay { RoundedRectangle(cornerRadius: 10).fill(.clear).stroke(.blue)
                            }
                    }
                    GoogleSignInButton {
                        Task {
                            do {
                                if try await userManager.googleSignIn() {
                                    authActive = true
                                } else {
                                    showingPrompt = true
                                }
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .clipped()
                    .shadow(radius: 4)
                    .frame(width: geometry.size.width * 0.5)
                    .padding(.top, 6)
                    .navigationDestination(isPresented: $showingPrompt) {
                        GoogleUsernamePromptView(activeView: $showingPrompt, active: $active)
                    }
                    .navigationDestination(isPresented: $authActive) {
                        AuthenticationView(active: $active)
                    }
                    Spacer()
                }
            }
        }
        .padding(.top)
    }
}
struct GoogleUsernamePromptView : View {
    @EnvironmentObject var userManager : UserManager
    @Binding var activeView : Bool
    @State var username : String = ""
    @Binding var active : Bool
    @State var confirmShowing : Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    Text("Create a Username")
                        .font(.title2)
                        .bold()
                        .padding()
                    TextField("Username", text: $username)
                        .frame(width: geometry.size.width * 0.8, alignment: .center)
                        .padding()
                        .background(Color(uiColor: .systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 5)
                    HStack {
                        Button {
                            userManager.signOut()
                            activeView = false
                        } label: {
                            Text("Cancel")
                                .foregroundStyle(.blue)
                                .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.125)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8).fill(.clear).stroke(.blue)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.trailing)
                        Button {
                            if !username.isEmpty {
                                confirmShowing = true
                            }
                        } label: {
                            Text("Continue")
                                .foregroundStyle(.white)
                                .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.125)
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .navigationDestination(isPresented: $confirmShowing) {
                            AuthenticationView(active: $active, username: username)
                        }
                    }
                }
                .frame(width: geometry.size.width, alignment: .center)
            }
        }
        .navigationBarBackButtonHidden()
    }
}
struct AuthenticationView : View {
    @EnvironmentObject var userManager : UserManager
    @Binding var active : Bool
    @State var username : String = ""
    @State var authSuccessful : Bool = false
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if authSuccessful {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25)
                        .foregroundStyle(.green)
                    Text("Done")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.green)
                } else {
                    HStack {
                        ProgressView()
                            .controlSize(.large)
                            .padding(5)
                        Text("Verifiying...")
                            .font(.title2)
                            .foregroundStyle(Color(uiColor: .systemGray))
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .task {
                do {
                    if userManager.gidUser == nil {
                        try await userManager.getGoogleHKWIUser(username: username)
                    } else {
                        try await userManager.signIn()
                    }
                    withAnimation(.easeInOut) {
                        authSuccessful = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        active = false
                        userManager.refresh()
                    }
                } catch {
                    Logger().error("\(error.localizedDescription)")
                    active = false
                }
            }
        }.navigationBarBackButtonHidden()
    }
}

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

import CoreLocation
import Foundation
import SwiftUI

struct ImageScanView : View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userManager: UserManager
    @State var image : UIImage
    @State var error : Bool = false
    @State var prediction : WildlifeEntry? = nil
    @State var progress : Double = 0
    
    @State private var userCoordinates: CLLocationCoordinate2D?
    @State private var locationManager = CLLocationManager()
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .clipped()
                    .padding(.horizontal)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                    .padding(.vertical)
                
                Text(prediction == nil ? "scanning..." : "Done")
                    .bold()
                ProgressView(value: progress)
                    .frame(width: geometry.size.width * 0.67)
                    .tint(.blue)
                Text(prediction?.name ?? "")
            }
            .onAppear {
                locationManager.delegate = LocationDelegate(userCoordinates: $userCoordinates)
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
            }
            .onReceive(timer) { _ in
                progress += Double.random(in: 0..<0.02)
                if progress >= 1 {
                    self.timer.upstream.connect().cancel()
                    SpeciesIdentifier().identifyAnimal(image: image) { result in
                        do {
                            let object = try result.get()
                            if let max = object.max(by: {$0.confidence < $1.confidence}) {
                                if max.confidence > 0.975 {
                                    if let data = image.pngData() {
                                        userManager.currentUser.photos.append(data)
                                    }
                                    userManager.currentUser.discovered.append(max.identifier.splitCamel())
                                    userManager.refresh()
                                    prediction = WildlifeIndex().entries.first(where: { $0.name.replacingOccurrences(of: " ", with: "") == max.identifier
                                    })
                                    if let coordanites = userCoordinates {
                                        MapManager().addMarker(
                                            WildlifeMarker(entryType: WildlifeIndex().entries.first(where: {$0.name == max.identifier.splitCamel()})!, position: coordanites, date: .now)
                                        )
                                    }
                                } else {
                                    error = true
                                }
                            }
                        }
                        catch {
                            self.error = true
                        }
                    }
                }
            }
            .sheet(item: $prediction) { item in
                VStack {
                    Text("Congratulations!")
                        .font(.title)
                        .bold()
                    Text("You found a \(item.name)")
                        .font(.title2)
                        .minimumScaleFactor(0.75)
                        .padding(.bottom)
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("OK")
                                .foregroundStyle(.white)
                                .padding()
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .clipped()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("View in library")
                                .foregroundStyle(.white)
                                .padding()
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .clipped()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
                .interactiveDismissDisabled()
            }
            .sheet(isPresented: $error) {
                VStack {
                    Text("Animal Could Not Be Identified")
                        .font(.title)
                        .bold()
                    Text("Please use a clearer photo")
                        .font(.title2)
                        .minimumScaleFactor(0.75)
                        .padding(.bottom)
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("OK")
                            .foregroundStyle(.white)
                            .padding()
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .clipped()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .interactiveDismissDisabled()
                
            }
        }
    }
}
class LocationDelegate: NSObject, CLLocationManagerDelegate {
    @Binding var userCoordinates: CLLocationCoordinate2D?

    init(userCoordinates: Binding<CLLocationCoordinate2D?>) {
        _userCoordinates = userCoordinates
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userCoordinates = location.coordinate
            manager.stopUpdatingLocation()
        }
    }
}

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

import Foundation
import SwiftUI

struct CameraView : View {
    @Environment(\.presentationMode) var presentationMode
    @State var takenImage : CIImage?
    @State var flashlightOn : Bool = false
    @State var zoomMode : Double = 1
    @State var zoomAdder : Double = 0.0
    @StateObject private var cameraModel : CameraModel = CameraModel()
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    ViewfinderView(image: $cameraModel.viewfinderImage)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    zoomMode = value.magnification
                                    zoomMode = zoomMode.clamp(1, 5)
                                    cameraModel.camera.modifyZoom(zoomMode)
                                }
                        )
                }
                .ignoresSafeArea()
                .overlay(alignment: .top) {
                    topButtonBar()
                        .navigationDestination(item: $takenImage) { item in
                            ImageScanView(image: UIImage(ciImage: item))
                        }
                }
                .overlay(alignment: .bottom) {
                    bottomButtonBar()
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .task {
            await cameraModel.camera.start()
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if (value.velocity.width > 500) {
                        presentationMode.wrappedValue.dismiss()
                        cameraModel.setFlashlight(0)
                    }
                }
                .onEnded { value in
                }
        )
    }
    func topButtonBar() -> some View {
        return
        GeometryReader { geo in
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                    cameraModel.setFlashlight(0)
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                }
                .padding(.leading, 30)
                Spacer()
                Button {
                    takenImage = cameraModel.photo
                } label: {
                    Text("Save")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                }
                .padding(.trailing, 30)
            }
            .frame(width: geo.size.width)
            .padding(.bottom, 30)
            .background(.black.opacity(0.6))
        }
    }
    func bottomButtonBar() -> some View {
        return
        GeometryReader { geo in
            VStack {
                VStack {
                    if zoomMode != 1 {
                        Button {
                            cameraModel.camera.modifyZoom(1.0)
                        } label: {
                            Image(systemName: "arrow.circlepath")
                                .foregroundStyle(.white)
                                .frame(width: 25, height: 25)
                                .padding(5)
                                .background(.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                }
                .frame(width: geo.size.width, alignment: .center)
            }
            .frame(height: geo.size.height * 0.875, alignment: .bottom)
            HStack {
                VStack {}
                .frame(width: 50, height: 50)
                .foregroundStyle(.white)
                Button {
                    cameraModel.camera.stop()
                } label: {
                    Image(systemName: "button.programmable")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 60)
                Button {
                    withAnimation(.easeInOut) {
                        flashlightOn.toggle()
                    }
                    cameraModel.setFlashlight(flashlightOn ? 1.0 : 0)
                } label: {
                    Image(systemName: "flashlight.\(flashlightOn ? "on" : "off").circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.white)
                }
            }
            .frame(width: geo.size.width)
            .padding(.top, 20)
            .background(.black.opacity(0.6))
            .frame(height: geo.size.height, alignment: .bottom)
        }
    }
}
#Preview {
    CameraView()
}
import Foundation
import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static let hongKong: Self = .init(
        latitude: 22.3193,
        longitude: 114.1694
    )
}
        
struct MapView : View {
    @State private var markers: [WildlifeMarker] = []
    @State private var showsFilters : Bool = false
    @State private var rarityFilter: [Rarity] = []
    
    @State var cameraBounds = MapCameraBounds(centerCoordinateBounds: MKCoordinateRegion(
        center: .hongKong,
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.25)
    ), minimumDistance: 1_000, maximumDistance: 150_000)
    
    @State private var mapCamPos: MapCameraPosition = .camera(MapCamera(
        centerCoordinate: .hongKong,
        distance: 125000
    ))
    
    @State private var selectedMarker : WildlifeMarker?
    
    var body: some View {
        Map(position: $mapCamPos, bounds: cameraBounds, selection: $selectedMarker) {
            ForEach(markers) { markerInfo in
                if rarityFilter.contains(markerInfo.type.rarity) || rarityFilter.isEmpty {
                    Marker(coordinate: markerInfo.position) {
                        Label(markerInfo.entryType, systemImage: markerInfo.type.symbol + ".fill")
                    }
                    .tag(markerInfo)
                    .tint(markerInfo.type.rarity.textView.color)
                }
            }
        }
        .task {
            markers = await MapManager().getMarkers()
        }
        .overlay(alignment: .bottom) {
            mapOverlay()
        }
        .sheet(item: $selectedMarker) { selectedPlacemark in
            MarkerDetailView(marker: selectedPlacemark)
            .presentationDetents([.height(350)])
        }
    }
    func mapOverlay() -> some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    Button {
                        withAnimation(.easeInOut) {
                            showsFilters.toggle()
                        }
                    } label: {
                        Image(systemName: "binoculars.fill")
                            .frame(width: geometry.size.width * 0.125, height: geometry.size.width * 0.125)
                            .background()
                            .clipShape(Circle())
                            .shadow(radius: 8)
                    }
                    .frame(width: geometry.size.width * 0.13, height: geometry.size.width * (showsFilters ? 0.5 : 0.125), alignment: .bottom)
                    .background()
                    .overlay(alignment: .top) {
                        if showsFilters {
                            VStack() {
                                ForEach(Rarity.allCases, id: \.self) { rarity in
                                    Button {
                                        if !rarityFilter.contains(rarity) {
                                            rarityFilter.append(rarity)
                                        } else {
                                            rarityFilter.removeFirst(where: {$0 == rarity})
                                        }
                                    } label: {
                                        Image(systemName: "leaf" + (rarityFilter.contains(rarity) ? ".fill" : ""))
                                            .frame(width: geometry.size.width * 0.05, height: geometry.size.width * 0.05)
                                            .foregroundStyle(rarity.textView.color)
                                        
                                    }
                                }
                            }
                            .padding(.top, geometry.size.width * 0.025)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .padding(.vertical, 5)
                    Button {
                        withAnimation(.easeInOut) {
                            mapCamPos = .camera(MapCamera(
                                centerCoordinate: .hongKong,
                                distance: 125000
                            ))
                        }
                    } label: {
                        Image(systemName: "house.fill")
                            .frame(width: geometry.size.width * 0.125, height: geometry.size.width * 0.125)
                            .background()
                            .clipShape(Circle())
                            .shadow(radius: 8)
                            .foregroundStyle(mapCamPos == .camera(MapCamera(
                                centerCoordinate: .hongKong,
                                distance: 125000
                            )) ? .gray : .blue)
                    }
                    .frame(width: geometry.size.width * 0.125, height: geometry.size.width * 0.125, alignment: .bottom)
                }
                .padding([.horizontal, .bottom])
                .frame(height: geometry.size.height, alignment: .bottom)
            }
            .frame(width: geometry.size.width, alignment: .trailing)
        }
    }
}
#Preview {
    MapView()
}
import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State var selection : Int = 1
    var body: some View {
        TabView(selection: $selection) {
            EntriesListView().tabItem { Label("Index", systemImage: "building.columns") }.tag(1)
            
            MapView().tabItem { Label("Map", systemImage: "map.fill") }.tag(2)
            
            ProfileView().tabItem { Label("Profile", systemImage: "person.fill") }.tag(3)
        }
    }
}

#Preview {
    ContentView()
}

import Foundation
import SwiftUI
import os.log
import SwiftData

final class HKWIUser : Codable {
    var gid: String?
    var username: String
    var password: String?
    
    var pfp: String = ""
    var discovered: [String] = []
    var level: Int = 1
    var xp: Double = 0
    var photos : [Data] = []
    var friends : [String] = []
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.gid = nil
    }
    init(username: String, gid: String) {
        self.username = username
        self.gid = gid
        self.password = nil
    }
    init() {
        self.username = "Local User"
        self.gid = nil
        self.password = nil
    }
}
func jsonEncode<T : Codable>(_ object: T) -> [String : Any]? {
    do {
        let jsonData = try JSONEncoder().encode(object)
        let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
        return dictionary
    }
    catch {
        Logger().error("\(error.localizedDescription)")
    }
    return nil
}


import Foundation
import CoreLocation
import SwiftData


public struct WildlifeMarker : Hashable, Identifiable, Codable {
    public static func == (lhs: WildlifeMarker, rhs: WildlifeMarker) -> Bool {
        return false//lhs.entryType == rhs.entryType
    }
    public let id: String = UUID().uuidString
    let entryType : String
    let date: String
    let lat: Double
    let long: Double
    
    init(entryType: WildlifeEntry, position: CLLocationCoordinate2D, date: Date) {
        self.entryType = entryType.name
        self.lat = position.latitude
        self.long = position.longitude
        self.date = date.formatted(date: .abbreviated, time: .shortened)
    }
    init(entryType: WildlifeEntry, latitude: Double, longitude: Double, date: Date) {
        self.entryType = entryType.name
        self.lat = latitude
        self.long = longitude
        self.date = date.formatted(date: .abbreviated, time: .shortened)
    }
    public var position: CLLocationCoordinate2D {
        return .init(latitude: lat, longitude: long)
    }
    public var type : WildlifeEntry {
        return WildlifeIndex().entries.first(where: {$0.name == self.entryType})!
    }
}
public let WildlifeMarkers : [WildlifeMarker] = [
    WildlifeMarker(entryType: WildlifeIndex().entries[0], position: .hongKong, date: .now),
]

import Foundation
import SwiftUI

public struct WildlifeEntry : Hashable, Identifiable {
    public static func == (lhs: WildlifeEntry, rhs: WildlifeEntry) -> Bool {
        return lhs.name == rhs.name
    }
    public let id: String = UUID().uuidString
    let name: String
    let latin: String
    let description: String
    
    let weight: String
    let size: String
    
    let classification: Classification
    
    let rarity: Rarity
    
    init(name: String, latin: String, description: String, weight: String, size: String, classification: Classification, rarity: Rarity) {
        self.name = name
        self.latin = latin
        self.description = description
        self.weight = weight
        self.size = size
        self.classification = classification
        self.rarity = rarity
        
    }
    var thumbnail : Image {
        return Image(uiImage: .init(named: self.name.replacingOccurrences(of: " ", with: "-") + "-0")!)
    }
    var symbol : String {
        if classification.kingdom == .plantae {
            return "leaf"
        }
        if classification.phylum == .arthropoda {
            return "ant"
        }
        if classification.classification == "mammalia" {
            return "paw"
        }
        if classification.family == "delphinidae" {
            return "fish"
        }
        return "pawprint"
    }
}
public class WildlifeIndex : ObservableObject {
    static var Common = 1
    static var Uncommon = 1
    static var Rare = 1
    static var Epic = 1
    static var Legendary = 1
    public var entries : [WildlifeEntry] = [
        WildlifeEntry(name: "Golden Orb Weaver", latin: "Nephila pilipes", description: "The Golden Orb Weaver spider, commonly found in Southeast Asia, is a breathtaking arachnid renowned for its striking appearance and remarkable web-spinning abilities. With a body length averaging around 4-5 centimeters, the spider boasts a vibrant golden hue, which glistens in the sunlight, earning it its resplendent name. Its delicate legs are adorned with intricate black and yellow patterns, adding to its visual allure. One of the most captivating features of this species is its intricately woven orb-shaped web, which can stretch up to one meter in diameter and is meticulously laced with golden silk. This web serves as both a trap to ensnare unsuspecting insects and a shelter for the spider itself. The Golden Orb Weaver's diet primarily consists of flying insects, and its venom, although harmless to humans, effectively immobilizes its prey. This magnificent spider, with its striking appearance and masterful web-spinning abilities, stands as an emblematic creature of the enchanting biodiversity found in Southeast Asia's lush and diverse ecosystems.", weight: "Female 7g, Male 3g", size: "Female 30mm, Male 6mm", classification: .aranae(infraorder: "araneomorphae", family: "nephilidae", genus: "nephila"), rarity: .rare),
        WildlifeEntry(name: "Striped Blue Crow", latin: "Euploea mulciber", description: "Euploea mulciber, also known as the Striped Blue Crow or Mulciber Crow, is a captivating butterfly species found in various parts of Asia. With its dark wings adorned by broad white or pale yellow stripes, this butterfly showcases a mesmerizing contrast that catches the eye. The adult butterfly has a wingspan ranging from 60 to 70 millimeters, and its upper side features a deep black coloration with distinct white stripes, while the undersides are brownish with lighter bands and markings. Euploea mulciber adds a touch of elegance to its surroundings as it gracefully flutters through its natural habitats.", weight: "<1g", size: "Wingspan: 90-110mm", classification: .nymphalidae(genus: "euploea"), rarity: .uncommon),
        WildlifeEntry(name: "Chinese Pangolin", latin: "Manis pentadactyla", description: "The Chinese pangolin (Manis pentadactyla) is a species of pangolin native to various regions in China and surrounding countries. It is a unique and fascinating mammal known for its distinctive appearance and remarkable adaptations. Covered in overlapping scales made of keratin, the Chinese pangolin has a slender body, a long snout, and a prehensile tail, which it uses for climbing trees and digging burrows. As an insectivorous creature, it primarily feeds on ants and termites, using its long, sticky tongue to capture its prey. Unfortunately, the Chinese pangolin faces significant threats due to habitat loss, illegal hunting, and trafficking, making it critically endangered. Efforts are being made to protect and conserve this remarkable species and raise awareness about the importance of biodiversity conservation.", weight: "2-10kg", size: "31-48cm", classification: .mammalia(order: "pholidota", family: "manidae", genus: "manus"), rarity: .legendary),
        WildlifeEntry(name: "Asian Needle Ant", latin: "Brachyponera chinensis", description: "The Asian needle ant (Pachycondyla chinensis) is one of the invasive ant species that has been reported. These ants are believed to have been introduced to the region through human activities, such as the transportation of goods and materials. In Hong Kong, they are known for their aggressive nature and ability to establish large colonies. Asian needle ants in Hong Kong primarily inhabit natural areas, including forests, grasslands, and wetlands. They construct nests in soil and leaf litter, and their presence can be particularly problematic in urban parks and gardens. Efforts are being made to monitor and manage the spread of these ants in order to minimize their impact on local ecosystems.", weight: "1-5mg", size: "8-12mm", classification: .ant(genus: "brachyponera"), rarity: .common),
        WildlifeEntry(name: "Wild Boar", latin: "Sus scrofa", description: "In Hong Kong, Sus scrofa, commonly known as the wild boar, represents a significant presence in the region's diverse wildlife. These large, omnivorous mammals inhabit the rural and forested areas, including country parks and nature reserves, that dot the territory. With their sturdy frames, muscular bodies, and distinctive curved tusks, wild boars are a robust species. Adult individuals can grow up to two meters in length and weigh between 100 to 200 kilograms. While generally avoiding urban areas, the expanding population of wild boars has led to occasional encounters with human settlements, necessitating efforts to manage and mitigate potential human-wildlife conflicts.", weight: "100-200kg", size: "1.5-2m", classification: .mammalia(order: "artiodactyla", family: "suidae", genus: "sus"), rarity: .epic),
        WildlifeEntry(name: "Chinese White Dolphin", latin: "Sousa chinensis", description: "The Chinese white dolphin, also known as the pink dolphin, is a captivating marine mammal that inhabits the waters surrounding Hong Kong. Renowned for its unique and striking appearance, this dolphin species showcases a captivating pinkish hue on its skin, making it a cherished icon of the region's marine biodiversity. The Chinese white dolphin possesses a graceful and streamlined body, reaching lengths of up to 2.5 meters and weighing around 200 kilograms. Their playful and social nature is often witnessed as they gracefully leap and frolic in the waves, captivating observers with their acrobatic displays. Unfortunately, these dolphins face numerous challenges due to habitat loss, water pollution, and increased maritime traffic. Conservation efforts are crucial to safeguard the future of these enchanting creatures, ensuring that they continue to grace Hong Kong's coastal waters with their presence for generations to come.", weight: "", size: "~2.7m", classification: .mammalia(order: "artiodactyla", family: "delphinidae", genus: "sousa"), rarity: .legendary),
        WildlifeEntry(name: "Black-Faced Spoonbill", latin: "Platalea minor", description: "Platalea minor, commonly known as the Black-faced Spoonbill, is a species of bird found in Hong Kong. It is characterized by its striking appearance, with a black face and bill, white plumage, and a distinctive spoon-shaped bill. The Black-faced Spoonbill is a rare and endangered species, with Hong Kong being one of its important breeding and wintering grounds, making it a valuable and protected bird in the region.", weight: "1.2kg", size: "60–78 cm long", classification: .aves(order: "    Pelecaniformes", family: "Threskiornithidae", genus: "Platalea"), rarity: .epic)
    ]
}


import Foundation
import SwiftUI

public struct Classification : Hashable {
    var domain: Domain
    var kingdom: Kingdom
    var phylum: Phylum
    var subphylum: Subphylum
    var classification: String
    var order: String
    var genus: String
    var family: String
    
    var list : [String] {
       return [
        domain.rawValue,
        kingdom.rawValue,
        phylum.rawValue,
        subphylum.rawValue,
        classification,
        order,
        genus,
        family,
        ]
    }
    static var hierarchy : [String] = [
        "Domain",
        "Kingdom",
        "Phylum",
        "Subphylum",
        "Classification",
        "Order",
        "Genus",
        "Family"
    ]
    
    init(domain: Domain, kingdom: Kingdom, phylum: Phylum, subphylum: Subphylum, classification: String, order: String, family: String, genus: String) {
        self.domain = domain
        self.kingdom = kingdom
        self.phylum = phylum
        self.subphylum = subphylum
        self.classification = classification
        self.order = order
        self.family = family
        self.genus = genus
    }
    func set(domain: Domain?, kingdom: Kingdom?, phylum: Phylum?, subphylum: Subphylum?, classification: String?, order: String?, infraorder: String?, family: String?, genus: String?) -> Classification {
        return Classification(domain: domain ?? self.domain,
                              kingdom: kingdom ?? self.kingdom,
                              phylum: phylum ?? self.phylum,
                              subphylum: subphylum ?? self.subphylum,
                              classification: classification ?? self.classification,
                              order: order ?? self.order,
                              family: family ?? self.family,
                              genus: genus ?? self.genus)
    }
    static func insecta(order: String, infraorder: String, family : String, genus: String) -> Self {
        return Classification(domain: .eukaryota, kingdom: .animalia, phylum: .arthropoda, subphylum: .none, classification: "insecta", order: order, family: family, genus: genus)
    }
    static func aranae(infraorder: String, family: String, genus: String) -> Self { Classification(domain: .eukaryota, kingdom: .animalia, phylum: .arthropoda, subphylum: .chelicerata, classification: "arachnida", order: "aranae", family: family, genus: genus)
    }
    
    static func nymphalidae(genus: String) -> Self { .insecta(order: "lepidoptera", infraorder: "", family: "nymphalidae", genus: genus)
    }
    static func mammalia(order: String, family: String, genus: String) -> Self {
        Classification(domain: .eukaryota, kingdom: .animalia, phylum: .chordata, subphylum: .none, classification: "mammalia", order: order, family: family, genus: genus)
    }
    static func ant(genus: String) -> Self {
        return .insecta(order: "Hymenoptera", infraorder: "", family: "Formicidae", genus: genus)
    }
    static func aves(order: String, family: String, genus: String) -> Self {
        return Classification(domain: .eukaryota, kingdom: .animalia, phylum: .chordata, subphylum: .none, classification: "Aves", order: order, family: family, genus: genus)
    }
}
enum Domain : String {
    case bacteria = "bacteria"
    case archaea = "archaea"
    case eukaryota = "eukaryota"
}
enum Kingdom : String {
    case animalia = "animalia"
    case plantae = "plantae"
    case fungi = "fungi"
    case protista = "protista"
    case eubacteria = "eubacteria"
    case archaebacteria = "archaebacteria"
}
enum Phylum : String {
    case porifera = "porifera"
    case cnidaria = "cnidaria"
    case platyhelminthe = "platyhelminthe"
    case nematoda = "nematoda"
    case annelida = "annelida"
    case arthropoda = "arthropoda"
    case mollusca = "mollusca"
    case echinodermata = "echinodermata"
    case chordata = "chordata"
}
enum Subphylum : String {
    case vertebrates = "vertebrates"
    case tunicates = "tunicates"
    case cephalochordates = "cephalochordates"
    case arthropods = "arthropods"
    case annelids = "annelids"
    case mollusks = "mollusks"
    case echinoderms = "echinoderms"
    case hemichordates = "hemichordates"
    case chordates = "chordates"
    case nematodes = "nematodes"
    case platyhelminthes = "platyhelminthes"
    case cnidarians = "cnidarians"
    case poriferans = "poriferans"
    case ctenophores = "ctenophores"
    case placozoans = "placozoans"
    case chelicerata = "chelicerata"
    case none
}
enum Rarity : CaseIterable, Hashable {
    case common
    case uncommon
    case rare
    case epic
    case legendary
}
extension Rarity {
    var textView : RarityViewBuilder {
        switch self {
        case .common:
            return .init(name: "Common", color: .gray, background: 0.4)
        case .uncommon:
            return .init(name: "Uncommon", color: .green, background: 0.6)
        case .rare:
            return .init(name: "Rare", color: .blue, background: 0.85)
        case .epic:
            return .init(name: "Epic", color: .purple, background: 0.6)
        case .legendary:
            return .init(name: "Legendary", color: .yellow, background: 0.8)
        }
    }
}
struct RarityViewBuilder {
    let name : String
    let color : Color
    let background : CGFloat

    init(name: String, color: Color, background: CGFloat) {
        self.name = name
        self.color = color
        self.background = background
    }
}
import AVFoundation
import SwiftUI
import os.log

final class CameraModel: ObservableObject {
    let camera = Camera()
    
    @Published var viewfinderImage: Image?
    @Published var photo: CIImage?
    var isPhotosLoaded = false
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image.image
                photo = image
            }
        }
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> Data? {
        guard let imageData = photo.fileDataRepresentation() else { return nil }

        guard let previewCGImage = photo.previewCGImageRepresentation(),
           let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)
        
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        
        return imageData
    }
    public func setFlashlight(_ brightness: Float) {
        guard let device = AVCaptureDevice.default(for: .video) else {
            Logger().error("Failed to obtain video input.")
            return
        }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if brightness == 0 {
                    device.torchMode = .off
                } else {
                    try device.setTorchModeOn(level: brightness)
                }
                device.unlockForConfiguration()
            } catch {
                Logger().error("\(error.localizedDescription)")
            }
        } else {
            Logger().error("Device has no flashlight.")
        }
    }
}

 struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

 extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

 extension Image.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}
import AVFoundation
import CoreImage
import UIKit
import os.log

class Camera: NSObject {
    private let captureSession = AVCaptureSession()
    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var sessionQueue: DispatchQueue!
    
    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera, .builtInDualWideCamera], mediaType: .video, position: .unspecified).devices
    }
    
    private var frontCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .front }
    }
    
    private var backCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .back }
    }
    
    private var captureDevices: [AVCaptureDevice] {
        var devices = [AVCaptureDevice]()
        #if os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
        devices += allCaptureDevices
        #else
        if let backDevice = backCaptureDevices.first {
            devices += [backDevice]
        }
        if let frontDevice = frontCaptureDevices.first {
            devices += [frontDevice]
        }
        #endif
        return devices
    }
    
    private var availableCaptureDevices: [AVCaptureDevice] {
        captureDevices
            .filter( { $0.isConnected } )
            .filter( { !$0.isSuspended } )
    }
    
    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            logger.debug("Using capture device: \(captureDevice.localizedName)")
            sessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }
    
    var isRunning: Bool {
        captureSession.isRunning
    }
    
    var isUsingFrontCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return frontCaptureDevices.contains(captureDevice)
    }
    
    var isUsingBackCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return backCaptureDevices.contains(captureDevice)
    }

    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    
    private var addToPreviewStream: ((CIImage) -> Void)?
    
    var isPreviewPaused = false
    
    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                if !self.isPreviewPaused {
                    continuation.yield(ciImage)
                }
            }
        }
    }()
    
    lazy var photoStream: AsyncStream<AVCapturePhoto> = {
        AsyncStream { continuation in
            addToPhotoStream = { photo in
                continuation.yield(photo)
            }
        }
    }()
        
    override init() {
        super.init()
        initialize()
    }
    
    private func initialize() {
        sessionQueue = DispatchQueue(label: "session queue")
        
        captureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(updateForDeviceOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        
        var success = false
        
        self.captureSession.beginConfiguration()
        
        defer {
            self.captureSession.commitConfiguration()
            completionHandler(success)
        }
        
        guard
            let captureDevice = captureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else {
            logger.error("Failed to obtain video input.")
            return
        }
        
        let photoOutput = AVCapturePhotoOutput()
                        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))
  
        guard captureSession.canAddInput(deviceInput) else {
            logger.error("Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            logger.error("Unable to add photo output to capture session.")
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            logger.error("Unable to add video output to capture session.")
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        
        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput
        
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        updateVideoOutputConnection()
        
        isCaptureSessionConfigured = true
        
        success = true
    }
    
    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            logger.debug("Camera access authorized.")
            return true
        case .notDetermined:
            logger.debug("Camera access not determined.")
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()
            return status
        case .denied:
            logger.debug("Camera access denied.")
            return false
        case .restricted:
            logger.debug("Camera library access restricted.")
            return false
        @unknown default:
            return false
        }
    }
    
    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let error {
            logger.error("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        if let deviceInput = deviceInputFor(device: captureDevice) {
            if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
        
        updateVideoOutputConnection()
    }
    
    private func updateVideoOutputConnection() {
        if let videoOutput = videoOutput, let videoOutputConnection = videoOutput.connection(with: .video) {
            if videoOutputConnection.isVideoMirroringSupported {
                videoOutputConnection.isVideoMirrored = isUsingFrontCaptureDevice
            }
        }
    }
    
    func start() async {
        let authorized = await checkAuthorization()
        guard authorized else {
            logger.error("Camera access was not authorized.")
            return
        }
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.async { [self] in
                    self.captureSession.startRunning()
                }
            }
            return
        }
        
        sessionQueue.async { [self] in
            self.configureCaptureSession { success in
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
    }
    
    func stop() {
        guard isCaptureSessionConfigured else { return }
        
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func switchCaptureDevice() {
        if let captureDevice = captureDevice, let index = availableCaptureDevices.firstIndex(of: captureDevice) {
            let nextIndex = (index + 1) % availableCaptureDevices.count
            self.captureDevice = availableCaptureDevices[nextIndex]
        } else {
            self.captureDevice = AVCaptureDevice.default(for: .video)
        }
    }
    func modifyZoom(_ value: CGFloat) {
        if let captureDevice = captureDevice {
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.videoZoomFactor = value.clamp(captureDevice.minAvailableVideoZoomFactor, captureDevice.maxAvailableVideoZoomFactor)
                captureDevice.unlockForConfiguration()
            } catch {
                Logger().error("Couldn't lock for config")
            }
        } else {
            self.captureDevice = AVCaptureDevice.default(for: .video)
        }
    }

    private var deviceOrientation: UIDeviceOrientation {
        var orientation = UIDevice.current.orientation
        if orientation == UIDeviceOrientation.unknown {
            orientation = UIScreen.main.orientation
        }
        return .portrait
    }
    
    @objc
    func updateForDeviceOrientation() {
        //TODO: Figure out if we need this for anything.
    }
    
    private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
        return .portrait
    }
    
    func takePhoto() {
        guard let photoOutput = self.photoOutput else { return }
        
        sessionQueue.async {
        
            var photoSettings = AVCapturePhotoSettings()

            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            photoSettings.photoQualityPrioritization = .balanced
            
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            logger.error("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        addToPhotoStream?(photo)
    }
}

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }

        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
    }
}

extension UIScreen {

    var orientation: UIDeviceOrientation {
        return .portrait
    }
}


import Foundation

extension BinaryFloatingPoint {
    func clamp(_ min: Self,_ max: Self) -> Self {
        return self > max ? max : self < min ? min : self
    }
}
public extension Array {
    @inlinable mutating func removeFirst(where isRemoved: (Self.Element) throws -> Bool) rethrows -> Self.Element? {
        for (index, element) in self.enumerated() {
            if try isRemoved(element) {
                self.remove(at: index)
                return element
            }
        }
        return nil
    }
}
public extension String {
    func splitCamel() -> Self {
        if self.isEmpty {return self}
        var str = self.split(separator: "").map {
            ($0.filter {$0.isUppercase} == $0) ? " " + $0 : $0
        }.joined()
        if str.first == " " {
            str.removeFirst()
        }
        return str
    }
}


import Foundation
import BCrypt
import os.log

class SecurityManager {
    func hash(_ input: String) -> String? {
        do {
            let salt = try BCrypt.Salt()
            let hashedString = try BCrypt.Hash.make(message: input, with: salt)
            return hashedString.makeString()
        } catch {
            Logger().error("Error hashing string: \(error.localizedDescription)")
            return nil
        }
    }
    func verify(_ password: String, hashedPassword: String) -> Bool {
        do {
            return try BCrypt.Hash.verify(message: password, matches: hashedPassword)
        } catch {
            Logger().error("Error verifying password: \(error.localizedDescription)")
            return false
        }
    }
}


import Foundation
import CoreML
import SwiftUI
import os.log
import CoreVideo
import Vision


class SpeciesIdentifier {
    let model : WildlifeClassifier? = try? WildlifeClassifier(configuration: MLModelConfiguration())
    
    func identifyAnimal(image: UIImage, completion: @escaping (Result<[VNClassificationObservation], Error>) -> Void) {
        guard let model = model else {
            Logger().error("Failed to initialize model")
            return
        }
        guard let vnModel = try? VNCoreMLModel(for: model.model) else {
            Logger().error("Failed to initialize vision model")
            return
        }
        guard let buffer = createBuffer(from: image) else {
            Logger().error("Failed to create buffer")
            return
        }
        do {
            let imageClassificationRequest = VNCoreMLRequest(model: vnModel) { (request, error) in
                if let error {
                    completion(.failure(error))
                }
                if let results = request.results as? [VNClassificationObservation] {
                    completion(.success(results))
                }
            }
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up)
            try requestHandler.perform([imageClassificationRequest])

            
            imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        } catch {
            completion(.failure(error))
        }
    }
    func createBuffer(from image: UIImage) -> CVPixelBuffer? {
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, options as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        
        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1, y: -1)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return buffer
    }
}
import Foundation
import FirebaseCore
import FirebaseFirestore
import os.log

class MapManager {
    func getMarkers() async -> [WildlifeMarker] {
        let markersDB = Firestore.firestore().collection("markers")
        do {
            let query = try await markersDB.getDocuments()
            let markers = try query.documents.map({
                try $0.data(as: WildlifeMarker.self)
            })
            return markers
        } catch {
            Logger().error("\(error.localizedDescription)")
        }
        return []
    }
    func addMarker(_ marker: WildlifeMarker) {
        let markersDB = Firestore.firestore().collection("markers")
        if let markerJson = jsonEncode(marker) {
            markersDB.addDocument(data: markerJson)
        }
    }
}
import Foundation
import SwiftUI
import GoogleSignIn
import os.log
import FirebaseFirestore
import BCrypt

enum SignInError : Error {
    case authFailed(description: String)
    case other
}
class UserManager : ObservableObject {
    @Published var hkwiUser : HKWIUser?
    @Published var gidUser : GIDGoogleUser?
    @Published var localUser : HKWIUser
    @Published var forceID : UUID = UUID()
    
    typealias ExistingUser = Bool
    
    public var loggedIn : Bool {
        return hkwiUser != nil
    }
    public var currentUser : HKWIUser {
        return loggedIn ? hkwiUser! : localUser
    }
    
    init(hkwiUser: HKWIUser? = nil, gidUser: GIDGoogleUser? = nil) {
        self.hkwiUser = hkwiUser
        self.gidUser = gidUser
        if let user = UserDefaults.standard.object(forKey: "savedUser") as? HKWIUser {
            localUser = user
        } else {
            localUser = HKWIUser()
        }
    }
    public func refresh() {
        forceID = UUID()
    }
    public func save() {
        
    }
    public func findUser(gid: String) async -> HKWIUser? {
        let users = Firestore.firestore().collection("users")
        let query = users.whereField("gid", isEqualTo: gid)
        do {
            if let doc = try await query.getDocuments().documents.first?.data(as: HKWIUser.self) as? HKWIUser {
                return doc
            }
        } catch {
            Logger().error("\(error.localizedDescription)")
            return nil
        }
        return nil
    }
    public func signIn() async throws {
        let users = Firestore.firestore().collection("users")
        guard let gid = gidUser?.userID else {throw SignInError.authFailed(description: "Google user not signed in")}
        if let doc = await findUser(gid: gid) {
            hkwiUser = doc
        } else {
            throw SignInError.authFailed(description: "User with specified GID does not exist")
        }
    }
    public func signIn(username: String, password: String) async throws {
        let users = Firestore.firestore().collection("users")
        let query = users.whereField("username", isEqualTo: username)
        do {
            if let doc = try await query.getDocuments().documents.first?.data(as: HKWIUser.self) as? HKWIUser {
                if SecurityManager().verify(password, hashedPassword: doc.password ?? "") {
                    DispatchQueue.main.async { [weak self] in
                        self?.hkwiUser = doc
                    }
                } else {
                    throw SignInError.authFailed(description: "Incorrect Password")
                }
            } else {
                registerUser(username, password)
            }
        } catch {
            throw error
        }
    }
    public func googleSignIn() async throws -> ExistingUser {
        if let vc = await (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController {
            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: vc)
                self.gidUser = result.user
                if let gid = gidUser?.userID {
                    return ((await findUser(gid: gid)) != nil)
                }
            }
            catch {
                throw error
            }
        }
        return false
    }
    public func getGoogleHKWIUser(username: String) async throws {
        let users = Firestore.firestore().collection("users")
        if let gid = gidUser?.userID {
            let query = users.whereField("gid", isEqualTo: gid)
            do {
                if let doc = try await query.getDocuments().documents.first?.data(as: HKWIUser.self) {
                    DispatchQueue.main.async { [weak self] in
                        self?.hkwiUser = doc
                    }
                } else {
                    registerGoogleUser(username: username)
                    try await signIn()
                }
            } catch {
                throw SignInError.authFailed(description: error.localizedDescription)
            }
        } else {
            throw SignInError.authFailed(description: "IDK what happened")
        }
    }
    private func registerGoogleUser(username: String) {
        guard let gid = gidUser?.userID else {return}
        let users = Firestore.firestore().collection("users")
        let user = HKWIUser(username: username, gid: gid)
        let userData = jsonEncode(user)!
        users.addDocument(data: userData)
    }
    private func registerUser(_ username: String, _ password: String) {
        let users = Firestore.firestore().collection("users")
        let user = HKWIUser(username: username, password: password)
        let userData = jsonEncode(user)!
        users.addDocument(data: userData)
    }
    public func signOut() {
        GIDSignIn.sharedInstance.signOut()
        hkwiUser = nil
    }
}

