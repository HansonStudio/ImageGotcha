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
    
    @IBOutlet weak var collectionView: SwipeSelectingCollectionView!
    @IBOutlet weak var selectBarButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photos: [Photo] = []
    var cellModels: [CellModel] = []
    var savePhotoManager = SavePhotoToDirectoryManager()
    var photosToSave: [Photo] = []
    var videosToSave: [URL?] = []

    var isSelectState = false
    
    
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
        selectAllButton.setTitle(LocalizedStr.cancelSelectAll, for: .selected)
        selectAllButton.setTitle(LocalizedStr.selectAll, for: .normal)
    }
    
    // MARK: - button Action
    
    @IBAction func close(_ sender: Any) {
        self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func toMulitiSelectImage(_ sender: Any) {
        setUpMultiSelectState()
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
            showSaveAction { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.setUpMultiSelectState()
                self?.showResultAlert()
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
        
        let imageUrlSet = Set(imageUrls)
        for urlString in Array(imageUrlSet) {
            var cellModel = CellModel()
            let photo = Photo(urlString: urlString)
            photos.append(photo)
            cellModel.photo = photo
            cellModels.append(cellModel)
        }

        collectionView.reloadData()
    }
    
    private func showResultAlert() {
        let ac = UIAlertController(title: "", message: LocalizedStr.saveSuccess, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: LocalizedStr.ok, style: .default))
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIApplication.presentedViewController(rootController: self)?.present(ac, animated: true, completion: nil)
        } else {
            let popoverController = ac.popoverPresentationController
            popoverController?.sourceView = self.view
            popoverController?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: 0, height: 0)
            UIApplication.presentedViewController(rootController: self)?.present(ac, animated: true, completion: nil)
        }
    }
    
    private func setUpMultiSelectState() {
        collectionView.isSwipeSelectingEnable = !isSelectState
        isSelectState = !isSelectState
        selectBarButton.title = isSelectState ? LocalizedStr.cancel : LocalizedStr.select
        
        bottomToolBar.isHidden = false
        let bottomConstant: CGFloat = isSelectState ? -44 : 44
        UIView.animate(withDuration: 0.3) {
            self.bottomToolBar.transform = CGAffineTransform(translationX: 0, y: bottomConstant)
        }
        
        if !isSelectState {
            for i in 0 ..< cellModels.count {
                cellModels[i].isSelected = false
                selectAllButton.isSelected = false
            }
            self.collectionView.reloadData()
        }
    }
}


// MARK: - AlertController

extension ActionViewController {
    
    func showSaveAction(_ finishHandler: (() -> Void)? = nil) {
        let photosAboutToSave = self.photosToSave
        
        let alert = UIAlertController(title: nil, message: LocalizedStr.savePhoto, preferredStyle: .actionSheet)
        // 保存到系统相册选项
        let saveToSystemAlbumAction = UIAlertAction(title: LocalizedStr.saveToSystemAlbum, style: .default) { [weak self] (action) in
            self?.activityIndicator.startAnimating()
            self?.savePhotoManager.saveToSystemAlbum(photosToSave: photosAboutToSave) {
                finishHandler?()
            }
        }
        // 保存到App内相册选项
        let saveToAppAlbumAction = UIAlertAction(title: LocalizedStr.saveToPrivateAlbum, style: .default) { [weak self] (action) in
            self?.activityIndicator.startAnimating()
            self?.savePhotoManager.savePhotoToShareDirectory(photosToSave: photosAboutToSave) {
                finishHandler?()
            }
        }
        // 取消选项
        let cancelAction = UIAlertAction(title: LocalizedStr.cancel, style: .cancel, handler: nil)
        
        alert.addAction(saveToSystemAlbumAction)
        alert.addAction(saveToAppAlbumAction)
        alert.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIApplication.presentedViewController(rootController: self)?.present(alert, animated: true, completion: nil)
        } else {
            let popoverController = alert.popoverPresentationController
            popoverController?.sourceView = self.view
            popoverController?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height, width: 0, height: 0)
            UIApplication.presentedViewController(rootController: self)?.present(alert, animated: true, completion: nil)
        }
    }
}


// MARK: - UICollectionViewDataSource

extension ActionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellModel = cellModels[indexPath.row]
        switch cellModel.cellModelType {
        case .image:
            let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configureCell(cellModel)
            return cell
        case .video:
            let cell: VideoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configureCell(cellModel)
            return cell
        }
    }
}


// MARK: - UICollectionViewDelegate

extension ActionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellModel = cellModels[indexPath.row]
        
        
        switch cellModel.cellModelType {
        case .image:
            let currentItem = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
            let currentPhoto = cellModel.photo
            if isSelectState {
                cellModels[indexPath.row].isSelected.toggle()
                currentItem.configureCell(cellModels[indexPath.row])
            } else {
                collectionView.deselectItem(at: indexPath, animated: false)
                currentPhoto?.image = currentItem.previewImageView.image
                let galleryPreview = PhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: currentItem)
                galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
                    guard let index = self?.cellModels.firstIndex(where: { $0.photo === photo }) else { return nil }
                    let selectedIndexPath = IndexPath(item: index, section: indexPath.section)
                    let cell = collectionView.cellForItem(at: selectedIndexPath) as? ImageCollectionViewCell
                    return cell?.previewImageView
                }
                galleryPreview.longPressGestureHandler = { [weak self] (photo, gesture) in
                    self?.photosToSave.removeAll()
                    self?.photosToSave.append(photo as! Photo)
                    self?.showSaveAction({
                        self?.activityIndicator.stopAnimating()
                    })
                }
                galleryPreview.actionButtonTappedHandler = { [weak self] (photo) in
                    self?.photosToSave.removeAll()
                    self?.photosToSave.append(photo as! Photo)
                    self?.showSaveAction({
                        self?.activityIndicator.stopAnimating()
                    })
                }
                self.present(galleryPreview, animated: true, completion: nil)
            }
        case .video:
            let currentItem = collectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell
            if isSelectState {
                cellModels[indexPath.row].isSelected = !cellModels[indexPath.row].isSelected
                currentItem.configureCell(cellModels[indexPath.row])
            } else {
                collectionView.deselectItem(at: indexPath, animated: false)
                guard cellModel.videoUrl != nil else { return }
                let player = AVPlayer(url: cellModel.videoUrl!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard isSelectState else { return }
        cellModels[indexPath.row].isSelected = !cellModels[indexPath.row].isSelected
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? ImageCollectionViewCell
        // 取消已经隐藏的 Cell 的下载任务
        cell?.previewImageView.kf.cancelDownloadTask()
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
                                        print("Video asset created")
                                    } else {
                                        print(error!)
                                    }
                            }
                        }
                    })
                    
                } catch { print(error) }
                
                }.resume()
            
        } else {
            print("File already exists at destination url")
            let destinationURL = documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent)
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                if authorizationStatus == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
                            if completed {
                                print("Video asset created")
                            } else {
                                print(error!)
                            }
                    }
                }
            })
        }
    }
}

