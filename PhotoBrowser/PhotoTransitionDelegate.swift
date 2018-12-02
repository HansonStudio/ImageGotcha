//
//  PhotoTransitionDelegate.swift
//  YMPhotoBrowser
//
//  Created by Hanson on 2018/3/22.
//  Copyright © 2018年 None. All rights reserved.
//

import Foundation
import UIKit

class PhotoTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    let interactiveAnimator: PhotosInteractionAnimator = PhotosInteractionAnimator()
    let transitionAnimator: PhotosTransitionAnimator = PhotosTransitionAnimator()
    var interactiveDismissal: Bool = false
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.dismissing = false
        return transitionAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.dismissing = true
        return transitionAnimator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveDismissal {
            interactiveAnimator.animator = transitionAnimator
            interactiveAnimator.shouldAnimateUsingAnimator = transitionAnimator.endingView != nil
            interactiveAnimator.viewToHideWhenBeginningTransition = transitionAnimator.startingView != nil ? transitionAnimator.endingView : nil
            
            return interactiveAnimator
        }
        return nil
    }
}
