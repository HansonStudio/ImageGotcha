//
//  ActionViewController.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2018/3/7.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import MobileCoreServices
import HSPhotoKit
import AVKit
import Photos
import Kingfisher
import Reusable

class ActionViewController: ImageGalleryViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photosToSave: [Photo] = []
    var videosToSave: [URL?] = []

    lazy var saveButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "tray.and.arrow.down", withConfiguration: largeConfig)
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(saveSinglePhoto), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        setupView()
        
        // ActionExtension 传过来的内容
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                self.getResourceUrls(provider: provider)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc override func bottomToolBarRightButtonDidTap(sender: UIButton) {
        photosToSave.removeAll()
        videosToSave.removeAll()
        for model in cellModels {
            if model.isSelected {
                if model.cellModelType == .image {
                    photosToSave.append(model.photo!)
                } else {
                    videosToSave.append(model.videoUrl)
                }
            }
        }
        if photosToSave.count > 0 || videosToSave.count > 0 {
            showSaveActionAlert(photos: photosToSave, sourceView: sender) { [weak self] in
                guard let self = self else { return }
                self.setEditing(!self.isEditing, animated: true)
            }
        }
    }
    
    private func configuration() {
        // ActionExtension 最大 120M 限制，这里配置最大 90M
        ImageCache.default.memoryStorage.config.totalCostLimit = 90 * 1024 * 1024
    }
    
    private func setupView() {
        collectionView.register(cellType: VideoCollectionViewCell.self)
        #if targetEnvironment(macCatalyst)
        collectionView.collectionViewLayout = iOSLayout
        #endif
        toolBarView.rightButton.setTitle(LocalizedStr.save, for: .normal)
        toolBarView.rightButton.setTitleColor(UIColor(rgba: "#2F8BF8"), for: .normal)
    }
    
    // MARK: - button Action
    
    @IBAction func close(_ sender: Any) {
        self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }
}


// MARK: - Function

extension ActionViewController {
    
    /// 处理 ActionExtension 传过来的图片/视频 URL
    private func getResourceUrls(provider: NSItemProvider) {
        let identifier = kUTTypePropertyList as String
        guard provider.hasItemConformingToTypeIdentifier(identifier) else { return }
        provider.loadItem(forTypeIdentifier: identifier, options: nil) { [weak self] (item, error) in
            let dictionary = item as! NSDictionary
            OperationQueue.main.addOperation {
                let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                var imageUrls = [String]()
                var videoUrls = [String]()
                if let urlStrings = results["imgURLs"] as? [String] {
                    imageUrls = urlStrings
                }
                if let videoUrlStrings = results["videoURLs"] as? [String] {
                    videoUrls.append(contentsOf: videoUrlStrings)
                }
                self?.setUpCellModels(imageUrls: imageUrls, videoUrls: videoUrls)
            }
        }
    }
    
    private func setUpCellModels(imageUrls: [String], videoUrls: [String]) {
        #if DEBUG
            for i in 0 ..< imageUrls.count {
                print("Image - " + "\(i) - : " + imageUrls[i])
            }
            for i in 0 ..< videoUrls.count {
                print("Video - " + "\(i): - " + videoUrls[i])
            }
        #endif
        
        cellModels.removeAll()
        photos.removeAll()
        
        for urlString in videoUrls {
            var cellModel = ImageGalleryCellModel()
            cellModel.cellModelType = .video
            cellModel.videoUrl = URL(string: urlString)
            cellModels.append(cellModel)
        }
        
        let imageUrlSet = imageUrls.removeDuplicate()
        for urlString in Array(imageUrlSet) {
            var cellModel = ImageGalleryCellModel()
            let photo = Photo(urlString: urlString)
            photos.append(photo)
            cellModel.photo = photo
            cellModels.append(cellModel)
        }

        collectionView.reloadData()
    }
    
    @objc func saveSinglePhoto(sender: UIButton) {
        guard let photo = galleryPreviewer?.currentPhoto as? Photo else { return }
        photosToSave.removeAll()
        photosToSave.append(photo)
        showSaveActionAlert(photos: photosToSave, sourceView: sender)
    }
}

extension ActionViewController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellModel = cellModels[indexPath.row]
        switch cellModel.cellModelType {
        case .image:
            let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configureCell(cellModel.photo)
            return cell
        case .video:
            let cell: VideoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configureCell(cellModel)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? ImageCollectionViewCell
        // 取消已经隐藏的 Cell 的下载任务
        cell?.imageView.kf.cancelDownloadTask()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            cellModels[indexPath.row].isSelected.toggle()
        } else {
            let cellModel = cellModels[indexPath.row]
            switch cellModel.cellModelType {
            case .image:
                let currentItem = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
                let currentPhoto = cellModel.photo
                collectionView.deselectItem(at: indexPath, animated: false)
                currentPhoto?.image = currentItem.imageView.image
                showGalleryPreviewer(currentPhoto: currentPhoto, currentItem: currentItem, actionButtons: [saveButton, shareButton])
            case .video:
                guard let videoUrl = cellModel.videoUrl else { return }
                let player = AVPlayer(url: videoUrl)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
        }
    }
}

extension ActionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemNum: CGFloat = 3
        var windowWidth = UIScreen.universalBounds.width
        #if targetEnvironment(macCatalyst)
        // ActionView Bounds (w: 960.0, h: 600.0) in macOS
        windowWidth = UIScreen.universalBounds.height
        #endif
        if UIDevice.current.userInterfaceIdiom == .pad {
            itemNum = 6
        }
        let itemSpace = 5 * (itemNum + 1)
        let itemWidth = (windowWidth - itemSpace) / itemNum
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

public extension Array where Element: Equatable {
    /// 去除数组重复元素
    func removeDuplicate() -> Array {
       return self.enumerated()
        .filter { self.firstIndex(of: $0.element) == $0.offset }
        .map { $0.element }
    }
}
