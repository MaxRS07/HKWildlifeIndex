
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
