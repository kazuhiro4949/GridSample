//
//  PhotoLibrary.swift
//  GridSample
//
//  Created by Kazuhiro Hayashi on 7/2/1 R.
//  Copyright © 1 Reiwa Kazuhiro Hayashi. All rights reserved.
//

import SwiftUI
import Combine
import Photos

class Asset: ObservableObject, Identifiable, Hashable {
    
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    @Published var image: UIImage? = nil
    
    let asset: PHAsset
    
    private var manager = PHImageManager.default()
    func request() {
        DispatchQueue.global().async {
            self.manager.requestImage(for: self.asset, targetSize: CGSize(width: 120, height: 120), contentMode: .aspectFill, options: nil) { [weak self] (image, info) in
                self?.image = image
            }
        }
    }
    
    init(asset: PHAsset) {
        self.asset = asset
    }
}

class PhotoLibrary: ObservableObject {
    
    @Published var photoAssets = [Asset]()
    
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            guard let self = self else { return }
            
            switch status {
            case .authorized:
                self.getAllPhotos()
            case .denied:
                break
            case .notDetermined:
                break
            case .restricted:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func getAllPhotos() {
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        var _photoAssets = [Asset]()
        assets.enumerateObjects { (asset, index, stop) in
            _photoAssets.append(Asset(asset: asset))
        }
        DispatchQueue.main.async { [weak self] in
            self?.photoAssets = _photoAssets
        }
        
    }
}

extension PHAsset: Identifiable {
}
