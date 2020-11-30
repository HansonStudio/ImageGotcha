//
//  SavePhotosManager.swift
//  SavePhotosKit
//
//  Created by Hanson on 2018/6/1.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import Photos
import Kingfisher
import KingfisherWebP

//操作结果
public enum SavePhotosResult {
    case success, error, denied
}

public typealias saveImageCompletion = (_ result: SavePhotosResult) -> Void

public class SavePhotosManager {

    
    public class func checkAuthorization(handler: @escaping (PHAuthorizationStatus) -> Void) {
        var currentStatus: PHAuthorizationStatus
        
        if #available(iOS 14, *) {
            currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            currentStatus = PHPhotoLibrary.authorizationStatus()
        }
        
        switch currentStatus {
        case .notDetermined:
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
                    handler(status)
                }
            } else {
                PHPhotoLibrary.requestAuthorization { (status) in
                    handler(status)
                }
            }
        default:
            handler(currentStatus)
        }
    }
    
    public class func saveImageInAlbum(images: [UIImage], completion: @escaping saveImageCompletion) {
        // 检查权限
        checkAuthorization() { status in
            
            if #available(iOS 14, *) {
                guard status == .authorized || status == .limited else { completion(.denied); return }
            } else {
                guard status == .authorized else { completion(.denied); return }
            }
            
            // 以 App 的名称作为相册名
            let infoDictionary = Bundle.main.infoDictionary!
            let albumName: String = infoDictionary["CFBundleDisplayName"] as! String
            
            // 创建相册
            createAssetCollection(name: albumName) { (result) in
                var assetAlbum: PHAssetCollection?
                switch result {
                case .success(let assetCollection):
                    assetAlbum = assetCollection
                case .failure(let error):
                    // 相册创建失败，则保存到系统相册
                    dPrint("--- Create Album Fail: \(error.localizedDescription)---")
                }
                
                //保存图片
                PHPhotoLibrary.shared().performChanges {
                    for image in images {
                        let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        if let album = assetAlbum {
                            let assetPlaceholder = result.placeholderForCreatedAsset
                            let albumChangeRequset = PHAssetCollectionChangeRequest(for: album)
                            albumChangeRequset!.addAssets([assetPlaceholder!] as NSArray)
                        }
                    }
                } completionHandler: { (isSuccess, error) in
                    if isSuccess {
                        completion(.success)
                    } else {
                        dPrint("--- PHAssetChangeRequest Error: \(error!.localizedDescription)")
                        completion(.error)
                    }
                }
            }
        }
    }
    
    public class func createAssetCollection(name: String, completion: @escaping (Result<PHAssetCollection, PhotoSaverError>) -> Void) {
        // .limited 的授权状态，无法创建相册
        if #available(iOS 14, *) {
            guard PHPhotoLibrary.authorizationStatus(for: .readWrite) != .limited else {
                completion(.failure(.limitedAccess))
                return
            }
        }
        
        // 判断指定名称的相册是否已存在
        var assetAlbum: PHAssetCollection?
        let list = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        list.enumerateObjects { (album, index, stop) in
            let assetCollection = album
            if name == assetCollection.localizedTitle {
                assetAlbum = assetCollection
                stop.initialize(to: true) // 停止遍历
            }
        }
        
        // 不存在则创建指定相册
        if assetAlbum == nil {
            var createAlbumRequest: PHAssetCollectionChangeRequest!
            var createdAlbumPlaceholder: PHObjectPlaceholder!
            PHPhotoLibrary.shared().performChanges {
                createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                createdAlbumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            } completionHandler: { (isSuccess, error) in
                guard isSuccess else {
                    completion(.failure(.createAlbumFail(description: error?.localizedDescription ?? "unknown")))
                    return
                }
                let fetchResult = PHAssetCollection.fetchAssetCollections(
                                    withLocalIdentifiers: [createdAlbumPlaceholder.localIdentifier],
                                    options: nil)
                let assetCollection = fetchResult.firstObject
                completion(.success(assetCollection!))
            }
        } else {
            completion(.success(assetAlbum!))
        }
    }
}

public enum PhotoSaverError: Error {
    case limitedAccess
    case createAlbumFail(description: String)
}

extension PhotoSaverError {
    public var localizedDescription: String {
        switch self {
        case .limitedAccess:
            return "权限不足"
        case .createAlbumFail(let description):
            return "创建相册失败: \(description)"
        }
    }
}

extension PHAuthorizationStatus {
    var description: String {
        switch self {
        case .authorized:
            return "authorized"
        case .denied:
            return "denied"
        case .limited:
            return "limited"
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        @unknown default:
            return "unknown"
        }
    }
}

extension ImageFormat {
    var fileExtension: String {
        switch self {
        case .GIF:
            return ".gif"
        case .JPEG:
            return ".jpeg"
        case .PNG:
            return ".png"
        case .unknown:
            return ".jpg"
        }
    }
}
