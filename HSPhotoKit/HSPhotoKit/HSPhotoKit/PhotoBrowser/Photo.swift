//
//  Photo.swift
//  HSPhotoKit
//
//  Created by Hanson on 2018/5/8.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher


public protocol PhotoViewable: class {
    var image: UIImage? { get }
    var imageURL: URL? { get set }
    
    func loadImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ())
    func getCachedImage(_ url: URL?, completion: @escaping ((_ image: UIImage?) -> Void))
    func getMemoryCachedImage() -> UIImage?
    func hasCachedImage(_ url: URL?) -> Bool
}

public class Photo: PhotoViewable {
    public var image: UIImage?
    public var imageURL: URL?
    
    public var isBase64Image: Bool = false
    public var imageDataProvider: ImageDataProvider?
    
    public var cachedKey: String? {
        if isBase64Image, let provider = imageDataProvider {
            return provider.cacheKey
        } else if let url = imageURL {
            return url.cacheKey
        } else {
            return nil
        }
    }
    
    public init(image: UIImage?) {
        self.image = image
    }

    public init(urlString: String) {
        imageURL = URL(string: urlString)
        if urlString.hasPrefix("data:image") {
            isBase64Image = true
            
            imageDataProvider = MyBase64ImageDataProvider(base64UrlString: urlString, cacheKey: imageURL?.cacheKey ?? "base64/\(UUID().uuidString)")
        }
    }
    
    public func loadImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        if let image = image {
            completion(image, nil)
            return
        }
        loadImageWithURL(imageURL, completion: completion)
    }
    
    public func getMemoryCachedImage() -> UIImage? {
        guard let cacheKey = cachedKey else { return nil }
        let cacheType = ImageCache.default.imageCachedType(forKey: cacheKey)
        if cacheType == .memory {
            let cachedImage = ImageCache.default.retrieveImageInMemoryCache(forKey: cacheKey)
            return cachedImage
        } else {
            return nil
        }
    }

    public func getCachedImage(_ url: URL?, completion: @escaping ((_ image: UIImage?) -> Void)) {
        guard let cacheKey = cachedKey else {
            completion(nil)
            return
        }
        let cacheType = ImageCache.default.imageCachedType(forKey: cacheKey)
        if cacheType == .memory {
            let cachedImage = ImageCache.default.retrieveImageInMemoryCache(forKey: cacheKey)
            completion(cachedImage)
        } else if cacheType == .disk {
            ImageCache.default.retrieveImageInDiskCache(forKey: cacheKey) { result in
                switch result {
                case .success(let image):
                    completion(image)
                case .failure(_):
                    completion(nil)
                }
            }
        }
    }

    public func hasCachedImage(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        return ImageCache.default.imageCachedType(forKey: url.cacheKey).cached
    }

    func loadImageWithURL(_ url: URL?, completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        guard let url = url else { return }
        ImageDownloader.default.downloadImage(with: url, options: nil) { (result) in
            switch result {
            case .success(let loadingResult):
                let image = loadingResult.image
                ImageCache.default.store(image, forKey: url.cacheKey)
                completion(image, nil)
            case .failure(_):
                completion(nil, NSError(domain: "PhotoDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't load image"]))
            }
        }
    }
}


// MARK: - MyBase64ImageDataProvider
public struct MyBase64ImageDataProvider: ImageDataProvider {
    public let base64UrlString: String
    public var cacheKey: String
    
    public init(base64UrlString: String, cacheKey: String) {
        self.base64UrlString = base64UrlString
        self.cacheKey = cacheKey
    }

    public func data(handler: (Result<Data, Error>) -> Void) {
        do {
            let data = try Data(contentsOf: URL(string: base64UrlString)!)
            handler(.success(data))
        } catch let error {
            handler(.failure(error))
        }
        
        /* Kingfisher 的 Base64ImageDataProvider 有问题
        let data = Data(base64Encoded: base64String, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        handler(.success(data))
         */
    }
}
