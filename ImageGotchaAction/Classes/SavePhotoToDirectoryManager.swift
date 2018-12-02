//
//  SavePhotoToDirectoryManager.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2018/5/7.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import PhotoBrowser

let AppGroupId: String = "group.com.hanson.imagegotcha"
public typealias FinishHandler = () -> Void

class SavePhotoToDirectoryManager: NSObject {

    var saveImageShareDirectory: URL?
    
    override init() {
        let shareDictory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupId)
        let imageFolder = shareDictory!.appendingPathComponent("Images", isDirectory: true)
        let exist = FileManager.default.fileExists(atPath: imageFolder.path)
        if !exist {
            try! FileManager.default.createDirectory(at: imageFolder, withIntermediateDirectories: true, attributes: nil)
        }
        saveImageShareDirectory = imageFolder
        
        print("group dictory: " + "\(String(describing: saveImageShareDirectory?.absoluteString))")
    }
}

extension SavePhotoToDirectoryManager {
    func savePhotoToShareDirectory(photosToSave: [Photo], _ finishHandler: FinishHandler? = nil) {
        for photo in photosToSave {
            let imageUrl = photo.imageURL
            if photo.hasCachedImage(imageUrl) {
                guard let image = photo.getCachedImage(imageUrl), let imageUrl = imageUrl else { continue }
                if let data = DefaultCacheSerializer.default.data(with: image, original: nil) {
                    let imagePath = imageUrl.cacheKey.kf.md5
                    let imagePahtUrl = saveImageShareDirectory?.appendingPathComponent(imagePath)
                    let isSaveSuccess = FileManager.default.createFile(atPath: imagePahtUrl!.path, contents: data, attributes: nil)
                    print("imagePath: " + "\(String(describing: imagePahtUrl))" + "\\n save success? " + "\(isSaveSuccess)")
                }
            }
        }
        finishHandler?()
    }
}
