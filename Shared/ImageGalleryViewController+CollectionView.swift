//
//  ImageGalleryViewController+CollectionView.swift
//  ImageGotcha
//
//  Created by Hanson on 2020/12/2.
//  Copyright © 2020 HansonStudio. All rights reserved.
//

import UIKit
import Reusable
import HSPhotoKit

extension ImageGalleryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configureCell(cellModels[indexPath.row])
        return cell
    }
}

extension ImageGalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            cellModels[indexPath.row].isSelected.toggle()
        } else {
            let currentPhoto = photos[indexPath.row]
            let currentItem = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
            collectionView.deselectItem(at: indexPath, animated: false)
            showGalleryPreviewer(currentPhoto: currentPhoto, currentItem: currentItem, actionButtons: [shareButton])
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
        // dPrint("\(#function)")
    }
    
}

// MARK: -

extension ImageGalleryViewController {
    
    func showGalleryPreviewer(currentPhoto: Photo? = nil, currentItem: UIView? = nil, actionButtons: [UIButton] = [], hideURLTextView: Bool = false) {
        galleryPreviewer = PhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: currentItem, actionButtons: actionButtons, isHideURLTextView: hideURLTextView)
        galleryPreviewer?.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            guard let self = self else { return nil }
            guard let index = self.photos.firstIndex(where: {$0 === photo}) else { return nil }
            let currentSelectedIndexPath = IndexPath(item: index, section: 0)
            if let cell = self.collectionView.cellForItem(at: currentSelectedIndexPath) as? ImageCollectionViewCell {
                return cell.imageView
            }
            return nil
        }
        present(galleryPreviewer!, animated: true, completion: nil)
    }
    
    @objc func shareImage(sender: UIButton) {
        guard let image = galleryPreviewer?.currentPhoto?.image else { return }
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
//        activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIApplication.presentedViewController(rootController: self)?.present(activityViewController, animated: true, completion: nil)
        } else {
            let popoverController = activityViewController.popoverPresentationController
            popoverController?.sourceView = sender
            popoverController?.sourceRect = sender.bounds
            UIApplication.presentedViewController(rootController: self)?.present(activityViewController, animated: true, completion: nil)
        }
    }
}
