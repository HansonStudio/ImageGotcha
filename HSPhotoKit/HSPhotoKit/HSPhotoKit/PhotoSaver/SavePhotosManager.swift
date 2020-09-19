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
        
        var assetAlbum: PHAssetCollection?
        let infoDictionary = Bundle.main.infoDictionary!
        let albumName: String = infoDictionary["CFBundleDisplayName"] as! String
        
        // 判断指定相册是否存在
        let list = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        list.enumerateObjects({ (album, index, stop) in
            let assetCollection = album
            if albumName == assetCollection.localizedTitle {
                assetAlbum = assetCollection
                stop.initialize(to: true)
            }
        })
        // 不存在则创建指定相册
        if assetAlbum == nil {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            }, completionHandler: { (isSuccess, error) in
                // 创建相册后，重新执行该方法
                self.saveImageInAlbum(images: images, completion: completion)
            })
            return
        }
        
        //保存图片
        PHPhotoLibrary.shared().performChanges({
            for image in images {
                let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = result.placeholderForCreatedAsset
                let albumChangeRequset = PHAssetCollectionChangeRequest(for: assetAlbum!)
//                PHAssetCollectionChangeRequest(for: PHAssetCollection)
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
