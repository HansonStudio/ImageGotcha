//
//  ImageCollectionViewCell.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2018/3/19.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var selectImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension ImageCollectionViewCell {
    func configureCell(_ model: CellModel) {
        guard let url = model.photo.imageURL else { return }
        previewImageView.kf.indicatorType = .activity
        previewImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        overlayView.isHidden = !model.isSelected
        selectImage.isHidden = !model.isSelected
        let scale: CGFloat = model.isSelected ? 0.95 : 1.0
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}
