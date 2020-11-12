
//
//  HSPhotoKit
//
//  Created by Hanson on 2019/9/27.
//  Copyright © 2019 HansonStudio. All rights reserved.
//

import UIKit

class ScalingImageView: UIScrollView {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        self.addSubview(imageView)
        return imageView
    }()
    
    var image: UIImage? {
        return imageView.image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageScrollView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageScrollView()
    }
    
    override var frame: CGRect {
        didSet {
            updateImageLayout()
        }
    }
    
    func setImage(with photo: Photo, completion: ((_ success: Bool) -> Void)? = nil) {
        imageView.kf.setImage(with: photo) { [weak self] result in
            switch result {
            case .success(let resultValue):
                self?.setImage(resultValue.image, animated: true)
                completion?(true)
            case .failure(let error):
                completion?(false)
                print("---ScalingImageView 加载失败: \(error.localizedDescription)")
            }
        }
    }
}


// MARK: - Function

extension ScalingImageView {
    private func setupImageScrollView() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        minimumZoomScale = 1
        maximumZoomScale = 2
    }
    
    func updateImageLayout() {
        setImage(imageView.image, animated: true)
    }
    
    func setImage(_ image: UIImage?, animated: Bool = false) {
        if let size = image?.size {
            var realSize = size
            let imageWidth = UIScreen.universalBounds.width
            realSize.width = imageWidth
            realSize.height = ceil(imageWidth * size.height / size.width)
            
            contentSize = CGSize(width: imageWidth, height: realSize.height)
            
            let frame = CGRect(x: (UIScreen.universalBounds.width - realSize.width) / 2.0,
                               y: realSize.height > bounds.height ? 0 : (bounds.height - realSize.height) / 2.0,
                               width: realSize.width, height: realSize.height)
            if frame.equalTo(imageView.frame) {
                return
            }
            if animated && imageView.frame.size != CGSize.zero {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { [weak self]() -> Void in
                    self?.imageView.frame = frame
                })
            } else {
                self.imageView.frame = frame
            }
        }
    }
}


// MARK: - UIGestureRecognizerDelegate

extension ScalingImageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 针对 长图 滑动到底部和顶部的处理
        guard otherGestureRecognizer.isMember(of: UIPanGestureRecognizer.self),
            let panGesture = otherGestureRecognizer as? UIPanGestureRecognizer else { return false }
        if contentSize.height - contentOffset.y <= frame.height {
            // 滑到图片底部
            let velocity = panGesture.velocity(in: panGesture.view)
            if velocity.y <= 0 {
                return true
            }
        } else if contentOffset.y <= 0 {
            // 滑到图片顶部
            let velocity = panGesture.velocity(in: panGesture.view)
            if velocity.y >= 0 {
                return true
            }
        }
        return false
    }
}
