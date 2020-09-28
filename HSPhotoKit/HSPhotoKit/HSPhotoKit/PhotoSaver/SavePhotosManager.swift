//
//  SavePhotosManager.swift
//  SavePhotosKit
//
//  Created by Hanson on 2018/6/1.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import Photos

//操作结果
public enum SavePhotosResult {
    case success, error, denied
}

public typealias saveImageCompletion = (_ result: SavePhotosResult?) -> Void

public class SavePhotosManager {
    
    class func isAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .notDetermined
    }
    
    public class func saveImageInAlbum(images: [UIImage], completion: saveImageCompletion?) {
        if !isAuthorized() {
            completion?(.denied)
            return
        }
        
        var assetAlbum: PHAssetCollection!
        let infoDictionary = Bundle.main.infoDictionary!
        // 以 App 的名称作为相册名
        let albumName: String = infoDictionary["CFBundleDisplayName"] as! String
        
        createAssetCollection(name: albumName) { (result) in
            switch result {
            case .success(let assetCollection):
                assetAlbum = assetCollection
            case .failure(let error):
                print("相册创建失败：\(error.localizedDescription)")
                // 相册创建失败，则保存到系统相册
                let list = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
                assetAlbum = list[0]
            }
            
            //保存图片
            PHPhotoLibrary.shared().performChanges({
                for image in images {
                    let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceholder = result.placeholderForCreatedAsset
                    let albumChangeRequset = PHAssetCollectionChangeRequest(for: assetAlbum)
                    albumChangeRequset!.addAssets([assetPlaceholder!] as NSArray)
                }
            }) { (isSuccess: Bool, error: Error?) in
                if isSuccess {
                    completion?(.success)
                } else{
                    print(error!.localizedDescription)
                    completion?(.error)
                }
            }
        }
    }
    
    public class func createAssetCollection(name: String, completion: @escaping (Result<PHAssetCollection, PhotoSaverError>) -> Void) {
        // .limited 的授权状态，无法创建相册，但系统不会报错
        if #available(iOSApplicationExtension 14, *) {
            guard PHPhotoLibrary.authorizationStatus() == .limited else {
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
            PHPhotoLibrary.shared().performChanges {
                createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            } completionHandler: { (isSuccess, error) in
                guard isSuccess else {
                    completion(.failure(.createAlbumFail(description: error?.localizedDescription ?? "unknown")))
                    return
                }
                let assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                let fetchResult = PHAssetCollection.fetchAssetCollections(
                                    withLocalIdentifiers: [assetCollectionPlaceholder.localIdentifier],
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
