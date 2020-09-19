//
//  VideoCollectionViewCell.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2018/7/30.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import Reusable

class VideoCollectionViewCell: UICollectionViewCell, Reusable {
    
    lazy var videoImageView = UIImageView(image: UIImage(named: "video"))
    lazy var selectImageView = UIImageView(image: UIImage(named: "select"))
    lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(videoImageView)
        self.contentView.addSubview(overlayView)
        self.contentView.addSubview(selectImageView)
        videoImageView.translatesAutoresizingMaskIntoConstraints = false
        selectImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        selectImageView.isHidden = true
        overlayView.isHidden = true
        
        let centerYConstraint = NSLayoutConstraint(item: videoImageView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1.0, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: videoImageView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0)
        self.addConstraints([centerYConstraint, centerXConstraint])
        
        let topConstraint = NSLayoutConstraint(item: selectImageView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: selectImageView, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1.0, constant: 0)
        self.addConstraints([topConstraint, rightConstraint])
        
        let overlayViewConstraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view]-|", options: .directionMask, metrics: nil, views: ["view": overlayView])
        self.addConstraints(overlayViewConstraintV)
        
        let overlayViewConstraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view]-|", options: .directionMask, metrics: nil, views: ["view": overlayView])
        self.addConstraints(overlayViewConstraintH)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoCollectionViewCell {
    func configureCell(_ model: CellModel) {
        overlayView.isHidden = !model.isSelected
        selectImageView.isHidden = !model.isSelected
        let scale: CGFloat = model.isSelected ? 0.95 : 1.0
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}

