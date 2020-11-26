//
//  AlbumViewController+CollectionView.swift
//  ImageGotcha
//
//  Created by Hanson on 2020/11/26.
//  Copyright © 2020 HansonStudio. All rights reserved.
//

import UIKit
import Reusable
import HSPhotoKit

extension AlbumViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AlbumCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configureCell(with: cellModels[indexPath.row])
        return cell
    }
}

extension AlbumViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            cellModels[indexPath.row].isSelected.toggle()
        } else {
            let currentPhoto = photos[indexPath.row]
            let currentItem = collectionView.cellForItem(at: indexPath) as! AlbumCollectionViewCell
            collectionView.deselectItem(at: indexPath, animated: false)
            let galleryPreview = PhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: currentItem, actionButtonStyle: .share, isHideURLTextView: true)
            galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
                if let index = self?.photos.firstIndex(where: {$0 === photo}) {
                    let currentSelectedIndexPath = IndexPath(item: index, section: indexPath.section)
                    if let cell = collectionView.cellForItem(at: currentSelectedIndexPath) as? AlbumCollectionViewCell {
                        return cell.imageView
                    }
                    return nil
                }
                return nil
            }
            galleryPreview.actionButtonTappedHandler = { [weak self] (photo) in
                self?.showShareImage(photo: photo)
            }
            self.present(galleryPreview, animated: true, completion: nil)
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

