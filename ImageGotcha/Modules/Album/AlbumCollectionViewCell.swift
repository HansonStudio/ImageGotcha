//
//  AlbumCollectionViewCell.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/5/8.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import HSPhotoKit
import Reusable

class AlbumCollectionViewCell: UICollectionViewCell, NibReusable {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var selectedView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override var isSelected: Bool {
        didSet {
            showSelectionOverlay()
        }
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        isSelected = false
//        showSelectionOverlay()
//    }
    
    func configureCell(with model: CellModel) {
        imageView.image = model.photo.image
        showSelectionOverlay()
    }
    
    func showSelectionOverlay() {
        overlayView.isHidden = !isSelected
        selectedView.isHidden = !isSelected
        let scale: CGFloat = isSelected ? 0.95 : 1.0
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}

struct CellModel {
    var isSelected: Bool = false
    var isSaved: Bool = false
    var photo: Photo = Photo(image: nil)
}
