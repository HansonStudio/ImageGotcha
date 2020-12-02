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

extension ImageGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemNum: CGFloat = 3
        let windowWidth = UIScreen.universalBounds.width
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isLandscape {
                itemNum = 6
            } else {
                itemNum = 4
            }
        }
        #if targetEnvironment(macCatalyst)
        itemNum = 6
        #endif
        let itemSpace = 5 * (itemNum - 1)
        let itemWidth = (windowWidth - itemSpace) / itemNum
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

// MARK: -

extension ImageGalleryViewController {
    
    func showGalleryPreviewer(currentPhoto: Photo? = nil, currentItem: UIView? = nil, actionButtons: [UIButton] = []) {
        galleryPreviewer = PhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: currentItem, actionButtons: actionButtons, isHideURLTextView: true)
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
    
    @objc func showShareImage() {
        guard let image = galleryPreviewer?.currentPhoto?.image else { return }
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
//        activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIApplication.presentedViewController(rootController: self)?.present(activityViewController, animated: true, completion: nil)
        } else {
            let popoverController = activityViewController.popoverPresentationController
            popoverController?.sourceView = self.view
            // TODO: - Test in iPad
//            popoverController?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height, width: 0, height: 0)
            UIApplication.presentedViewController(rootController: self)?.present(activityViewController, animated: true, completion: nil)
        }
    }
}
