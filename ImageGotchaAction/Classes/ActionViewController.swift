//
//  ActionViewController.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2018/3/7.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import MobileCoreServices
import SavePhotosKit
import PhotoBrowser
import AVKit
import Photos

class ActionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
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
        
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: "VideoCollectionViewCell")
        
        // ActionExtension 传过来的内容
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                self.getResourceUrls(provider: provider)
            }
        }
        
        selectAllButton.setTitle(LocalizedStr.cancelSelectAll, for: .selected)
        selectAllButton.setTitle(LocalizedStr.selectAll, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                    photosToSave.append(model.photo)
                } else {
                    videosToSave.append(model.videoUrl)
                }
            }
        }
        if photosToSave.count > 0 || videosToSave.count > 0 {
            showSaveAction { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.setUpMultiSelectState()
            }
        }
    }
    
    @IBAction func toSelectAll(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        for i in 0 ..< cellModels.count {
            cellModels[i].isSelected = sender.isSelected
        }
        self.collectionView.reloadData()
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
                    if let insVideoUrls = results["insVideoUrls"] as? [String] {
                        videoUrls = insVideoUrls
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
        
        for urlString in videoUrls {
            var cellModel = CellModel()
            cellModel.cellModelType = .video
            cellModel.videoUrl = URL(string: urlString)
            cellModels.append(cellModel)
        }
        
        photos.removeAll()
        let imageUrlSet = Set(imageUrls)
        for url in Array(imageUrlSet) {
            let photo = Photo(imageURL: URL(string: url), thumbnailImageURL: URL(string: url))
            photos.append(photo)
            var cellModel = CellModel()
            cellModel.photo = photo
            cellModels.append(cellModel)
        }
        
        self.collectionView.reloadData()
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
        let alert = UIAlertController(title: nil, message: LocalizedStr.savePhoto, preferredStyle: .actionSheet)
        // 保存到系统相册选项
        let saveToSystemAlbumAction = UIAlertAction(title: LocalizedStr.saveToSystemAlbum, style: .default) { [weak self] (action) in
            self?.activityIndicator.startAnimating()            
            var imageToSave: [UIImage] = []
            for photo in (self?.photosToSave)! {
                let imageUrl = photo.imageURL
                if photo.hasCachedImage(imageUrl) {
                    guard let image = photo.getCachedImage(imageUrl) else { continue }
                    imageToSave.append(image)
                }
            }
            
            if let videosUrls = self?.videosToSave {
                for url in videosUrls {
                    guard url != nil else { return }
                    self?.downloadVideoLinkAndCreateAsset(url!)
                }
            }
            
            SavePhotosManager.saveImageInAlbum(images: imageToSave, completion: { (result) in
                DispatchQueue.main.async {
                    finishHandler?()
                    self?.showResultAlert()
                }
            })
        }
        // 保存到App内相册选项
        let saveToAppAlbumAction = UIAlertAction(title: LocalizedStr.saveToPrivateAlbum, style: .default) { [weak self] (action) in
            self?.activityIndicator.startAnimating()
            self?.savePhotoManager.savePhotoToShareDirectory(photosToSave: self?.photosToSave ?? [], {
                finishHandler?()
                self?.showResultAlert()
            })
        }
        
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(cellModels[indexPath.row])
            return cell
        case .video:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as? VideoCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(cellModels[indexPath.row])
            return cell
        }
    }
}


// MARK: - UICollectionViewDelegate

extension ActionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellModel = cellModels[indexPath.row]
        let currentItem = collectionView.cellForItem(at: indexPath)
        
        switch cellModel.cellModelType {
        case .image:
            let currentPhoto = cellModel.photo
            if isSelectState {
                cellModels[indexPath.row].isSelected = !cellModels[indexPath.row].isSelected
                if let currentItem = currentItem as? ImageCollectionViewCell {
                    currentItem.configureCell(cellModels[indexPath.row])
                }
                
            } else {
                let galleryPreview = PhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: currentItem)
                galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
                    if let index = self?.cellModels.index(where: { $0.photo === photo }) {
                        let currentSelectedIndexPath = IndexPath(item: index, section: indexPath.section)
                        if let cell = collectionView.cellForItem(at: currentSelectedIndexPath) as? ImageCollectionViewCell {
                            return cell.previewImageView
                        }
                        return nil
                    }
                    return nil
                }
                galleryPreview.longPressGestureHandler = { [weak self] (photo, gesture) in
                    self?.photosToSave.removeAll()
                    self?.photosToSave.append(photo as! Photo)
                    self?.showSaveAction({
                        self?.activityIndicator.stopAnimating()
                    })
                }
                galleryPreview.downloadButtonTappedHandler = { [weak self] (photo) in
                    self?.photosToSave.removeAll()
                    self?.photosToSave.append(photo as! Photo)
                    self?.showSaveAction({
                        self?.activityIndicator.stopAnimating()
                    })
                }
                self.present(galleryPreview, animated: true, completion: nil)
            }
        case .video:
            if isSelectState {
                cellModels[indexPath.row].isSelected = !cellModels[indexPath.row].isSelected
                if let currentItem = currentItem as? VideoCollectionViewCell {
                    currentItem.configureCell(cellModels[indexPath.row])
                }
                
            } else {
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
        print("deselct")
    }
}

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

