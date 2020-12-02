//
//  ImageCollectionViewCell.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/5/8.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import HSPhotoKit
import Reusable
import SnapKit
import Kingfisher

class ImageCollectionViewCell: UICollectionViewCell, Reusable {

    var imageView: AnimatedImageView!
    var overlayView: UIView!
    var selectedView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            showSelectionOverlay()
        }
    }
    
    func configureCell(_ model: ImageGalleryCellModel) {
        imageView.image = model.photo?.image
    }
    
    func configureCell(_ photo: Photo?) {
        guard let photo = photo else { return }
        // call layoutIfNeeded, In order to get the correct imageView.bounds.size
        layoutIfNeeded()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: photo, size: imageView.bounds.size)
    }
    
    func showSelectionOverlay() {
        overlayView.isHidden = !isSelected
        selectedView.isHidden = !isSelected
        let scale: CGFloat = isSelected ? 0.95 : 1.0
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    private func setupView() {
        contentView.clipsToBounds = true
        // 针对大 GIF 图优化，不会加载所有的图片祯
        imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        contentView.addSubview(overlayView)
        overlayView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        overlayView.isHidden = true
        
        selectedView = UIImageView(image: UIImage(named: "select"))
        contentView.addSubview(selectedView)
        selectedView.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
        }
        selectedView.isHidden = true
    }
}


public enum CellModelType: Int {
    case image, video
}

public struct ImageGalleryCellModel {
    public var isSelected: Bool = false
    public var isSaved: Bool = false
    public var photo: Photo?
    public var videoUrl: URL?
    public var cellModelType: CellModelType = .image
}
