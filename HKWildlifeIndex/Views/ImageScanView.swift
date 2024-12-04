
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
