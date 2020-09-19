//
//  ImageCollectionViewCell.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2018/3/19.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import Kingfisher
import HSPhotoKit
import Reusable
import SnapKit

class ImageCollectionViewCell: UICollectionViewCell, Reusable {
    
    var previewImageView: UIImageView!
    var overlayView: UIView!
    var selectImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            overlayView.isHidden = !isSelected
            selectImage.isHidden = !isSelected
            let scale: CGFloat = isSelected ? 0.95 : 1.0
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
    
    private func setupView() {
        contentView.clipsToBounds = true
        // 针对大 GIF 图优化，不会加载所有的图片祯
        previewImageView = AnimatedImageView()
        previewImageView.contentMode = .scaleAspectFill
        contentView.addSubview(previewImageView)
        previewImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        overlayView = UIImageView()
        overlayView.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        contentView.addSubview(overlayView)
        overlayView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        overlayView.isHidden = true
        
        selectImage = UIImageView(image: UIImage(named: "select"))
        contentView.addSubview(selectImage)
        selectImage.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
        }
        selectImage.isHidden = true
    }
}

extension ImageCollectionViewCell {
    func configureCell(_ model: CellModel) {
        guard let photo = model.photo else { return }
        layoutIfNeeded()
        previewImageView.kf.indicatorType = .activity
        previewImageView.kf.setImage(with: photo, size: previewImageView.bounds.size)
//        previewImageView.kf.setImage(with: photo)
    }
}
