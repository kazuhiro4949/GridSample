//
//  ContentView.swift
//  GridSample
//
//  Created by Kazuhiro Hayashi on 7/1/1 R.
//  Copyright © 1 Reiwa Kazuhiro Hayashi. All rights reserved.
//

import SwiftUI
import Photos
import Combine

struct ContentView : View {
    @ObservedObject var photoLibrary = PhotoLibrary()

    var body: some View {
        Grid(self.photoLibrary.photoAssets, id: \.self) {
            PhotoRow(photo: $0).frame(width: 120, height: 120)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            self.photoLibrary.requestAuthorization()
        }
    }
}

struct PhotoRow: View {
    @ObservedObject var photo: Asset
    @State private var isDisappeard = false
    var body: some View {
        HStack {
            if photo.image != nil {
                Image(uiImage: photo.image!)
                    .frame(width: 120, height: 120)
                    .scaledToFill()
                    .clipped()
            } else {
                Color.white.frame(width: 120, height: 120)
            }
        }.onAppear {
            self.isDisappeard = false
            self.photo.request()
        }.onDisappear {
            self.isDisappeard = true
        }
    }
}
#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif


