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
    func showSaveActionAlert(photos: [Photo], sourceView: UIView? = nil, finishHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: LocalizedStr.savePhoto, preferredStyle: .actionSheet)
        
        // 保存到系统相册选项
        let saveToSystemAlbumAction = UIAlertAction(title: LocalizedStr.saveToSystemAlbum, style: .default) { [weak self] (action) in
            self?.showActivityIndicator()
            PhotoSaver.shared.saveToSystemAlbum(photosToSave: photos) { result in
                self?.dismissActivityIndicator()
                self?.showAlert(with: result)
                finishHandler?()
            }
        }
        // 保存到App内相册选项
        let saveToAppAlbumAction = UIAlertAction(title: LocalizedStr.saveToPrivateAlbum, style: .default) { [weak self] (action) in
            self?.showActivityIndicator()
            PhotoSaver.shared.savePhotoToShareDirectory(photosToSave: photos) { result in
                self?.dismissActivityIndicator()
                self?.showAlert(with: result)
                finishHandler?()
            }
        }
        // 取消选项
        let cancelAction = UIAlertAction(title: LocalizedStr.cancel, style: .cancel, handler: nil)
        
        alert.addAction(saveToSystemAlbumAction)
        alert.addAction(saveToAppAlbumAction)
        alert.addAction(cancelAction)
        
        showAlert(alert, soureView: sourceView)
    }
    
    func showAlert(with result: Result<Int?, Error>) {
        var message = ""
        switch result {
        case .success(let count):
            if let count = count {
                message = LocalizedStr.saveSuccess + " : \(count)"
            } else {
                message = LocalizedStr.saveSuccess
            }
        case .failure(let error):
            message = LocalizedStr.saveFail + " : \(error.localizedDescription)"
        }
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
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
    
    func showAlert(_ alert: UIAlertController, soureView: UIView? = nil) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIApplication.presentedViewController(rootController: self)?.present(alert, animated: true, completion: nil)
        } else {
            let popoverController = alert.popoverPresentationController
            popoverController?.sourceView = soureView
            popoverController?.sourceRect = soureView?.bounds ?? CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: 0, height: 0)
            UIApplication.presentedViewController(rootController: self)?.present(alert, animated: true, completion: nil)
        }
    }
}
