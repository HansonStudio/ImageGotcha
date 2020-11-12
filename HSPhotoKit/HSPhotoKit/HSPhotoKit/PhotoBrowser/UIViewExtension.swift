//
//  HSPhotoKit
//
//  Created by Hanson on 2019/9/27.
//  Copyright © 2019 HansonStudio. All rights reserved.
//


import UIKit

extension UIView {
    // TODO: - What's this for
    func snapshotView() -> UIView {
//        if let contents = layer.contents {
//            var snapshotedView: UIView!
//
//            if let view = self as? UIImageView {
//                snapshotedView = type(of: view).init(image: view.image)
//                snapshotedView.bounds = view.bounds
//            } else {
//                snapshotedView = UIView(frame: frame)
//                snapshotedView.layer.contents = contents
//                snapshotedView.layer.bounds = layer.bounds
//            }
//            snapshotedView.layer.cornerRadius = layer.cornerRadius
//            snapshotedView.layer.masksToBounds = layer.masksToBounds
//            snapshotedView.contentMode = contentMode
//            snapshotedView.transform = transform
//
//            return snapshotedView
//        } else {
//            return snapshotView(afterScreenUpdates: true)!
//        }
        return snapshotView(afterScreenUpdates: true)!
    }

    func translatedCenterPointToContainerView(_ containerView: UIView) -> CGPoint {
        var centerPoint = center

        // Special case for zoomed scroll views.
        if let scrollView = self.superview as? UIScrollView , scrollView.zoomScale != 1.0 {
            centerPoint.x += (scrollView.bounds.width - scrollView.contentSize.width) / 2.0 + scrollView.contentOffset.x
            centerPoint.y += (scrollView.bounds.height - scrollView.contentSize.height) / 2.0 + scrollView.contentOffset.y
        }
        return self.superview?.convert(centerPoint, to: containerView) ?? CGPoint.zero
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }.first?.windows
            .filter { $0.isKeyWindow }.first
    }
    
    var activeWindowScene: UIWindowScene? {
        self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }.first
    }
}
