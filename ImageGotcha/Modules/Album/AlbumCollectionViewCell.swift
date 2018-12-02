//
//  AlbumCollectionViewCell.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/5/8.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import PhotoBrowser

class AlbumCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var selectedView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

extension AlbumCollectionViewCell {
    func configureCell(_ model: CellModel) {
        imageView.image = model.photo.image
        overlayView.isHidden = !model.isSelected
        selectedView.isHidden = !model.isSelected
        let scale: CGFloat = model.isSelected ? 0.95 : 1.0
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}

struct CellModel {
    var isSelected: Bool = false
    var isSaved: Bool = false
    var photo: Photo = Photo(imageURL: nil, thumbnailImageURL: nil)
}
