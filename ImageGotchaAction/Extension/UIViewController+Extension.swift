//
//  UIViewController+Extension.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2020/9/27.
//  Copyright © 2020 HansonStudio. All rights reserved.
//

import UIKit
import HSPhotoKit

extension UIViewController {
    func showSaveAction(photos: [Photo], _ finishHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: LocalizedStr.savePhoto, preferredStyle: .actionSheet)
        
        // 保存到系统相册选项
        let saveToSystemAlbumAction = UIAlertAction(title: LocalizedStr.saveToSystemAlbum, style: .default) { [weak self] (action) in
            self?.showActivityIndicator()
            PhotoSaver.shared.saveToSystemAlbum(photosToSave: photos) {
                self?.dismissActivityIndicator()
                self?.showResultAlert()
                finishHandler?()
            }
        }
        // 保存到App内相册选项
        let saveToAppAlbumAction = UIAlertAction(title: LocalizedStr.saveToPrivateAlbum, style: .default) { [weak self] (action) in
            self?.showActivityIndicator()
            PhotoSaver.shared.savePhotoToShareDirectory(photosToSave: photos) {
                self?.dismissActivityIndicator()
                self?.showResultAlert()
                finishHandler?()
            }
        }
        // 取消选项
        let cancelAction = UIAlertAction(title: LocalizedStr.cancel, style: .cancel, handler: nil)
        
        alert.addAction(saveToSystemAlbumAction)
        alert.addAction(saveToAppAlbumAction)
        alert.addAction(cancelAction)
        
        showAlert(alert)
    }
    
    func showResultAlert() {
        let alert = UIAlertController(title: "", message: LocalizedStr.saveSuccess, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedStr.ok, style: .default))
        showAlert(alert)
    }
    
    func showActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let centerX = activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let centerY = activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        NSLayoutConstraint.activate([centerX, centerY])
    }
    
    func dismissActivityIndicator() {
        view.subviews.filter { ($0 as? UIActivityIndicatorView) != nil }.forEach { $0.removeFromSuperview() }
    }
    
    func showAlert(_ alert: UIAlertController) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIApplication.presentedViewController(rootController: self)?.present(alert, animated: true, completion: nil)
        } else {
            let popoverController = alert.popoverPresentationController
            popoverController?.sourceView = self.view
            popoverController?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: 0, height: 0)
            UIApplication.presentedViewController(rootController: self)?.present(alert, animated: true, completion: nil)
        }
    }
}
