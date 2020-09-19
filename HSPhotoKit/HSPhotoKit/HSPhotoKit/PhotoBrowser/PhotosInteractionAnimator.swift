//
//  HSPhotoKit
//
//  Created by Hanson on 2019/9/27.
//  Copyright © 2019 HansonStudio. All rights reserved.
//


import UIKit

class PhotosInteractionAnimator: NSObject, UIViewControllerInteractiveTransitioning {
    var animator: UIViewControllerAnimatedTransitioning?
    var viewToHideWhenBeginningTransition: UIView?
    var shouldAnimateUsingAnimator: Bool = false
    
    private var transitionContext: UIViewControllerContextTransitioning?
    
}


// MARK: - UIViewControllerInteractiveTransitioning

extension PhotosInteractionAnimator {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        viewToHideWhenBeginningTransition?.alpha = 0.0
        self.transitionContext = transitionContext
    }
}


// MARK: - Public Function

extension PhotosInteractionAnimator {
    func handlePanWithPanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer, viewToPan: UIView, anchorPoint: CGPoint) {
        guard let fromView = transitionContext?.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        // 拖动图片，改变图片位置
        let translatedPanGesturePoint = gestureRecognizer.translation(in: fromView)
        let newCenterPoint = CGPoint(x: anchorPoint.x + translatedPanGesturePoint.x, y: anchorPoint.y + translatedPanGesturePoint.y)
        viewToPan.center = newCenterPoint
        
        // 拖动图片，改变背景透明度
        let verticalDelta = newCenterPoint.y - anchorPoint.y
        let backgroundAlpha = backgroundAlphaForPanningWithVerticalDelta(verticalDelta)
        fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(backgroundAlpha)
        
        // 拖动图片时候，缩放图片
        var scaleTransForm = CGAffineTransform.identity
        scaleTransForm = scaleTransForm.scaledBy(x: backgroundAlpha, y: backgroundAlpha)
        viewToPan.transform = scaleTransForm
        
        if gestureRecognizer.state == .ended {
            finishPanWithPanGestureRecognizer(gestureRecognizer, verticalDelta: verticalDelta,viewToPan: viewToPan, anchorPoint: anchorPoint)
        }
    }
    
    func finishPanWithPanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer, verticalDelta: CGFloat, viewToPan: UIView, anchorPoint: CGPoint) {
        guard let fromView = transitionContext?.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        let returnToCenterVelocityAnimationRatio = 0.00007
        let panDismissDistanceRatio = 50.0 / 667.0 // distance over iPhone 6 height
        let panDismissMaximumDuration = 0.45
        
        let velocityY = gestureRecognizer.velocity(in: gestureRecognizer.view).y
        
        var animationDuration = (Double(abs(velocityY)) * returnToCenterVelocityAnimationRatio) + 0.2
        var animationCurve: UIView.AnimationOptions = .curveEaseOut
        var finalPageViewCenterPoint = anchorPoint
        var finalBackgroundAlpha = 1.0
        
        let dismissDistance = panDismissDistanceRatio * Double(fromView.bounds.height)
        let isDismissing = Double(abs(verticalDelta)) > dismissDistance
        
        var didAnimateUsingAnimator = false
        
        if isDismissing {
            if let animator = self.animator, let transitionContext = transitionContext , shouldAnimateUsingAnimator {
                animator.animateTransition(using: transitionContext)
                didAnimateUsingAnimator = true
            } else {
                let isPositiveDelta = verticalDelta >= 0
                let modifier: CGFloat = isPositiveDelta ? 1 : -1
                let finalCenterY = fromView.bounds.midY + modifier * fromView.bounds.height
                finalPageViewCenterPoint = CGPoint(x: fromView.center.x, y: finalCenterY)
                
                animationDuration = Double(abs(finalPageViewCenterPoint.y - viewToPan.center.y) / abs(velocityY))
                animationDuration = min(animationDuration, panDismissMaximumDuration)
                animationCurve = .curveEaseOut
                finalBackgroundAlpha = 0.0
            }
        }
        
        if didAnimateUsingAnimator {
            self.transitionContext = nil
        } else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: { () -> Void in
                viewToPan.center = finalPageViewCenterPoint
                fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(CGFloat(finalBackgroundAlpha))
                viewToPan.transform = CGAffineTransform.identity
                
            }, completion: { finished in
                if isDismissing {
                    self.transitionContext?.finishInteractiveTransition()
                } else {
                    self.transitionContext?.cancelInteractiveTransition()
                }
                
                self.viewToHideWhenBeginningTransition?.alpha = 1.0
                self.transitionContext?.completeTransition(isDismissing && !(self.transitionContext?.transitionWasCancelled ?? false))
                self.transitionContext = nil
            })
        }
    }
}


// MARK: - Private Function

extension PhotosInteractionAnimator {
    private func backgroundAlphaForPanningWithVerticalDelta(_ delta: CGFloat) -> CGFloat {
        guard let fromView = transitionContext?.view(forKey: UITransitionContextViewKey.from) else {
            return 0.0
        }
        let startingAlpha: CGFloat = 1.0
        let finalAlpha: CGFloat = 0.1
        let totalAvailableAlpha = startingAlpha - finalAlpha
        
        let maximumDelta = CGFloat(fromView.bounds.height / 3.0)
        let deltaAsPercentageOfMaximum = min(abs(delta) / maximumDelta, 1.0)
        let changeAlpha = startingAlpha - (deltaAsPercentageOfMaximum * totalAvailableAlpha)
//        print("delta: " + "\(delta)")
//        print("deltaAsPercentageOfMaximum: " + "\(deltaAsPercentageOfMaximum)")
//        print("changeAlpha: " + "\(changeAlpha)")
        return changeAlpha
    }
}
