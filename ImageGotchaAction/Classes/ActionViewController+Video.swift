//
//  ActionViewController+Video.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2020/12/2.
//  Copyright © 2020 HansonStudio. All rights reserved.
//

import Foundation
import Photos

// MARK: - Download Video; Not Been Used
extension ActionViewController {
    func downloadVideoLinkAndCreateAsset(_ videoURL: URL) {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localVideoURL = documentURL.appendingPathComponent(videoURL.lastPathComponent)
        if !FileManager.default.fileExists(atPath: localVideoURL.path) {
            saveVideo(url: videoURL)
        } else {
            dPrint("File already exists at destination url")
            let destinationURL = documentURL.appendingPathComponent(videoURL.lastPathComponent)
            saveVideo(url: destinationURL)
        }
    }
    
    func downloadVideo(url: URL) {
        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            guard let location = location else { return }
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentURL.appendingPathComponent(response?.suggestedFilename ?? url.lastPathComponent)
            do {
                try FileManager.default.moveItem(at: location, to: destinationURL)
                self.saveVideo(url: destinationURL)
            } catch {
                dPrint(error)
            }
        }
        task.resume()
    }
    
    func saveVideo(url: URL) {
        PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
            guard authorizationStatus == .authorized else { return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { (completed, error) in
                dPrint("Video asset created \(completed); error: \(String(describing: error?.localizedDescription))")
            }
        })
    }
}
