//
//  CameraView.swift
//  HKWildlifeIndex
//
//  Created by Max Siebengartner on 25/3/2024.
//

import Foundation
import SwiftUI

struct CameraView : View {
    @Environment(\.presentationMode) var presentationMode
    @State var imageTaken : Bool = false
    @StateObject private var cameraModel : CameraModel = CameraModel()
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height
                
                ZStack {
                    ViewfinderView(image: $cameraModel.viewfinderImage)
                    Color.blue
                }
                .ignoresSafeArea()
                .overlay(alignment: .top) {
                    topButtonBar()
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
    }
    func topButtonBar() -> some View {
        return
        GeometryReader { geo in
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
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
                    presentationMode.wrappedValue.dismiss()
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
            HStack {
                Button {
                    cameraModel.camera.takePhoto()
                } label: {
                    Image(systemName: "button.programmable")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.white)
                }
                
            }
            .frame(width: geo.size.width)
            .padding(.top, 30)
            .background(.black.opacity(0.6))
            .frame(height: geo.size.height, alignment: .bottom)
            
        }
    }
}
#Preview {
    CameraView()
}
