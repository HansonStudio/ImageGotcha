//
//  PhotoSaver.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2018/5/7.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import HSPhotoKit
import Kingfisher

let AppGroupId: String = "group.com.hanson.imagegotcha"
public typealias SavePhotoFinishHandler = (Result<Int?, Error>) -> Void

class PhotoSaver {

    static let shared = PhotoSaver()
    
    var saveImageShareDirectory: URL?
    
    private init() {
        let shareDictory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupId)
        let imageFolder = shareDictory!.appendingPathComponent("Images", isDirectory: true)
        let exist = FileManager.default.fileExists(atPath: imageFolder.path)
        if !exist {
            try! FileManager.default.createDirectory(at: imageFolder, withIntermediateDirectories: true, attributes: nil)
        }
        saveImageShareDirectory = imageFolder
        
        dPrint("group dictory: " + "\(String(describing: saveImageShareDirectory?.absoluteString))")
    }
    
    func savePhotoToShareDirectory(photosToSave: [Photo], _ finishHandler: SavePhotoFinishHandler? = nil) {
        let savingDispatchGroup = DispatchGroup()
        var savedCount = 0
        for photo in photosToSave {
            savingDispatchGroup.enter()
            photo.getCachedImage { (image) in
                if let image = image, let data = DefaultCacheSerializer.default.data(with: image, original: nil) {
                    let imagePath = photo.cachedKey?.kf.md5 ?? ""
                    let imagePahtUrl = self.saveImageShareDirectory?.appendingPathComponent(imagePath)
                    let isSaveSuccess = FileManager.default.createFile(atPath: imagePahtUrl!.path, contents: data, attributes: nil)
                    if isSaveSuccess {
                        savedCount += 1
                    }
                    dPrint("--imagePath: " + "\(String(describing: imagePahtUrl))" + " save success? " + "\(isSaveSuccess)")
                }
                savingDispatchGroup.leave()
            }
        }
        savingDispatchGroup.notify(queue: .main) {
            finishHandler?(.success(savedCount))
        }
    }
    
    func saveToSystemAlbum(photosToSave: [Photo], _ finishHandler: SavePhotoFinishHandler? = nil) {
        let savingDispatchGroup = DispatchGroup()
        var imagesToSave = [UIImage]()
        for photo in photosToSave {
            savingDispatchGroup.enter()
            photo.getCachedImage { (image) in
                if let image = image {
                    imagesToSave.append(image)
                }
                savingDispatchGroup.leave()
            }
        }
        savingDispatchGroup.notify(queue: .main) {
            SavePhotosManager.saveImageInAlbum(images: imagesToSave) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        finishHandler?(.success(nil))
                    case .failure(let error):
                        finishHandler?(.failure(error))
                    }
                }
            }
        }
    }
}
