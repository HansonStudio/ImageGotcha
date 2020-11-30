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

class ActionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectBarButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photos: [Photo] = []
    var cellModels: [CellModel] = []
    var photosToSave: [Photo] = []
    var videosToSave: [URL?] = []

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
    
    private func configuration() {
        // ActionExtension 最大 120M 限制，这里配置最大 90M
        ImageCache.default.memoryStorage.config.totalCostLimit = 90 * 1024 * 1024
    }
    
    private func setupView() {
        collectionView.register(cellType: ImageCollectionViewCell.self)
        collectionView.register(cellType: VideoCollectionViewCell.self)
        collectionView.allowsMultipleSelection = false
        if #available(iOS 14.0, *) {
            // ⚠️ iOS 14 需配置这个属性后，其实不需要再调用 shouldBeginMultipleSelectionInteractionAt delegate 方法
            collectionView.allowsSelectionDuringEditing = true
            collectionView.allowsMultipleSelectionDuringEditing = true
        }
        selectAllButton.setTitle(LocalizedStr.cancelSelectAll, for: .selected)
        selectAllButton.setTitle(LocalizedStr.selectAll, for: .normal)
    }
    
    // MARK: - button Action
    
    @IBAction func close(_ sender: Any) {
        self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func toMulitiSelectImage(_ sender: Any) {
        setEditing(!isEditing, animated: true)
    }
    
    @IBAction func toSave(_ sender: Any) {
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
            showSaveAction(photos: photosToSave) { [weak self] in
                guard let self = self else { return }
                self.setEditing(!self.isEditing, animated: true)
            }
        }
    }
    
    @IBAction func toSelectAll(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        for i in 0 ..< cellModels.count {
            cellModels[i].isSelected = sender.isSelected
        }
        for index in 0..<cellModels.count {
            let indexPath = IndexPath(item: index, section: 0)
            if sender.isSelected {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
            } else {
                collectionView.deselectItem(at: indexPath, animated: true)
            }
        }
    }
}


// MARK: - Function

extension ActionViewController {
    
    /// 处理 ActionExtension 传过来的图片/视频 URL
    ///
    /// - Parameter provider: NSItemProvider
    private func getResourceUrls(provider: NSItemProvider) {
        if provider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
            provider.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { [weak self] (item, error) in
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
            })
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
            var cellModel = CellModel()
            cellModel.cellModelType = .video
            cellModel.videoUrl = URL(string: urlString)
            cellModels.append(cellModel)
        }
        
        let imageUrlSet = imageUrls.removeDuplicate()
        for urlString in Array(imageUrlSet) {
            var cellModel = CellModel()
            let photo = Photo(urlString: urlString)
            photos.append(photo)
            cellModel.photo = photo
            cellModels.append(cellModel)
        }

        collectionView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        guard isEditing != editing else { return }
        super.setEditing(editing, animated: animated)
        // 注意开启关闭多选(目前测试发现 iOS14 上 CollectionView 单个手指也能触发多选)
        collectionView.allowsMultipleSelection = editing
        if #available(iOS 14.0, *) {
            collectionView.allowsMultipleSelectionDuringEditing = editing
        }
        clearSelectedItems(animated: true)
        updateRightBarButtonTitle()
        updateBottomToolBar()
        if !editing {
            selectAllButton.isSelected = false
        }
    }
    
    func clearSelectedItems(animated: Bool) {
        collectionView.indexPathsForSelectedItems?.forEach({ (indexPath) in
            collectionView.deselectItem(at: indexPath, animated: animated)
        })
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    func updateRightBarButtonTitle() {
        guard let button = navigationItem.rightBarButtonItem else { return }
        button.title = isEditing ? LocalizedStr.cancel : LocalizedStr.select
    }
    
    func updateBottomToolBar() {
        bottomToolBar.isHidden = false
        let bottomConstant: CGFloat = isEditing ? -44 : 44
        UIView.animate(withDuration: 0.3) {
            self.bottomToolBar.transform = CGAffineTransform(translationX: 0, y: bottomConstant)
        }
    }
    
    func saveSinglePhoto(_ photo: Photo) {
        photosToSave.removeAll()
        photosToSave.append(photo)
        showSaveAction(photos: photosToSave)
    }

}

// MARK: - 视频下载（暂不用）
extension ActionViewController {
    func downloadVideoLinkAndCreateAsset(_ videoURL: URL) {
//        guard let videoURL = URL(string: videoLink) else { return }
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path) {
            URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in
                guard let location = location else { return }
                let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
                
                do {
                    try FileManager.default.moveItem(at: location, to: destinationURL)
                    PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                        if authorizationStatus == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
                                    if completed {
                                        dPrint("Video asset created")
                                    } else {
                                        print(error!)
                                    }
                            }
                        }
                    })
                    
                } catch { print(error) }
                
                }.resume()
            
        } else {
            dPrint("File already exists at destination url")
            let destinationURL = documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent)
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                if authorizationStatus == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
                            if completed {
                                dPrint("Video asset created")
                            } else {
                                print(error!)
                            }
                    }
                }
            })
        }
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
