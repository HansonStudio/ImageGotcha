//
//  ActionViewController+CollectionView.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2020/11/26.
//  Copyright © 2020 HansonStudio. All rights reserved.
//

import Foundation
import UIKit
import Reusable
import HSPhotoKit
import AVKit

extension ActionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellModel = cellModels[indexPath.row]
        switch cellModel.cellModelType {
        case .image:
            let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configureCell(cellModel)
            return cell
        case .video:
            let cell: VideoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configureCell(cellModel)
            return cell
        }
    }
}

extension ActionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? ImageCollectionViewCell
        // 取消已经隐藏的 Cell 的下载任务
        cell?.previewImageView.kf.cancelDownloadTask()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellModel = cellModels[indexPath.row]
        switch cellModel.cellModelType {
        case .image:
            let currentItem = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
            let currentPhoto = cellModel.photo
            if isEditing {
                cellModels[indexPath.row].isSelected.toggle()
                currentItem.configureCell(cellModels[indexPath.row])
            } else {
                collectionView.deselectItem(at: indexPath, animated: false)
                currentPhoto?.image = currentItem.previewImageView.image
                let galleryPreview = PhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: currentItem)
                galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
                    guard let index = self?.cellModels.firstIndex(where: { $0.photo === photo }) else { return nil }
                    let selectedIndexPath = IndexPath(item: index, section: indexPath.section)
                    let cell = collectionView.cellForItem(at: selectedIndexPath) as? ImageCollectionViewCell
                    return cell?.previewImageView
                }
                galleryPreview.longPressGestureHandler = { [weak self] (photo, gesture) in
                    guard let self = self else { return }
                    self.saveSinglePhoto(photo as! Photo)
                }
                galleryPreview.actionButtonTappedHandler = { [weak self] (photo) in
                    guard let self = self else { return }
                    self.saveSinglePhoto(photo as! Photo)
                }
                self.present(galleryPreview, animated: true, completion: nil)
            }
        case .video:
            let currentItem = collectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell
            if isEditing {
                cellModels[indexPath.row].isSelected = !cellModels[indexPath.row].isSelected
                currentItem.configureCell(cellModels[indexPath.row])
            } else {
                collectionView.deselectItem(at: indexPath, animated: false)
                guard cellModel.videoUrl != nil else { return }
                let player = AVPlayer(url: cellModel.videoUrl!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard isEditing else { return }
        cellModels[indexPath.row].isSelected.toggle()
    }
    
    // MARK: - Multiple selection methods.
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        // Returning `true` automatically sets `collectionView.allowsMultipleSelection`
        // to `true`.
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        // Replace the Select button with Done, and put the
        // collection view into editing mode.
        setEditing(true, animated: true)
    }
    
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        // print("\(#function)")
    }
    
}


