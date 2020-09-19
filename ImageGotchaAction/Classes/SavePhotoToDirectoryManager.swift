//
//  SavePhotoToDirectoryManager.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2018/5/7.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import HSPhotoKit
import Kingfisher

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
        let savingDispatchGroup = DispatchGroup()
        
        for photo in photosToSave {
            guard let imageUrl = photo.imageURL
                , photo.hasCachedImage(imageUrl) else { continue }
            
            savingDispatchGroup.enter()
            
            photo.getCachedImage(imageUrl) { (image) in
                guard let image = image else {
                    savingDispatchGroup.leave()
                    return
                }
                
                if let data = DefaultCacheSerializer.default.data(with: image, original: nil) {
                    let imagePath = imageUrl.cacheKey.kf.md5
                    let imagePahtUrl = self.saveImageShareDirectory?.appendingPathComponent(imagePath)
                    let isSaveSuccess = FileManager.default.createFile(atPath: imagePahtUrl!.path, contents: data, attributes: nil)
                    print("--imagePath: " + "\(String(describing: imagePahtUrl))" + "\\n save success? " + "\(isSaveSuccess)")
                }
                
                savingDispatchGroup.leave()
            }
        }
        savingDispatchGroup.notify(queue: .main) {
            print("---结束存储(SharedDirectory)---")
            finishHandler?()
        }
    }
    
    func saveToSystemAlbum(photosToSave: [Photo], _ finishHandler: FinishHandler? = nil) {
        let savingDispatchGroup = DispatchGroup()
        
        var imagesToSave = [UIImage]()
        for photo in photosToSave {
            guard let imageUrl = photo.imageURL
                , photo.hasCachedImage(imageUrl) else { continue }
            
            savingDispatchGroup.enter()
            
            photo.getCachedImage(imageUrl) { (image) in
                guard let image = image else {
                    savingDispatchGroup.leave()
                    return
                }
                imagesToSave.append(image)
                
                savingDispatchGroup.leave()
            }
        }
        savingDispatchGroup.notify(queue: .main) {
            SavePhotosManager.saveImageInAlbum(images: imagesToSave) { (result) in
                DispatchQueue.main.async {
                    print("---结束存储(SystemAlbum)---")
                    finishHandler?()
                }
            }
        }
    }
}
