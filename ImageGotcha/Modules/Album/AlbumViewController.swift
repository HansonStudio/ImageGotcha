//
//  AlbumViewController.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/4/22.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import SnapKit
import HSPhotoKit
import Blueprints
import Reusable

class AlbumViewController: ImageGalleryViewController {
    
    var saveImageShareDirectory: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizedStr.album
        getShareDirectory()
        getImageData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc override func bottomToolBarRightButtonDidTap(sender: UIButton) {
        deleteImage()
    }
}

// MARK: - Private Function
extension AlbumViewController {
    private func getShareDirectory() {
        let shareDictory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupId)
        let imageFolder = shareDictory!.appendingPathComponent("Images", isDirectory: true)
        let exist = FileManager.default.fileExists(atPath: imageFolder.path)
        if !exist {
            do {
                try FileManager.default.createDirectory(at: imageFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                dPrint("error to create share directory")
            }
        }
        saveImageShareDirectory = imageFolder
    }
    
    private func getImageData() {
        guard let saveImageShareDirectory = saveImageShareDirectory else { return }
        do {
            photos.removeAll()
            cellModels.removeAll()
            let imageNames = try FileManager.default.contentsOfDirectory(atPath: saveImageShareDirectory.path)
            for imageName in imageNames {
                let imageURL = saveImageShareDirectory.appendingPathComponent(imageName)
                let imageDataPath = imageURL.path
                if let imageData = FileManager.default.contents(atPath: imageDataPath) {
                    let image = UIImage(data: imageData)
                    let photo = Photo(image: image)
                    photos.append(photo)
                    var cellModel = ImageGalleryCellModel()
                    cellModel.photo = photo
                    cellModel.photo?.imageURL = imageURL
                    cellModels.append(cellModel)
                }
            }
            self.collectionView.reloadData()
            
        } catch {
            
        }
    }
    
    private func deleteImage() {
        var photoToDelete = [Photo]()
        for model in cellModels {
            if model.isSelected {
                photoToDelete.append(model.photo!)
            }
        }
        for item in photoToDelete {
            guard let url = item.imageURL else { continue }
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error {
                dPrint(" Error: \(error.localizedDescription)")
            }
        }
        getImageData()
        toggleSelectionMode()
    }
}
