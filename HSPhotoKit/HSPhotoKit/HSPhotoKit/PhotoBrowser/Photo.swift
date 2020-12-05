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
import KingfisherWebP
import Photos

public protocol PhotoViewable: class {
    var image: UIImage? { get }
    var imageURL: URL? { get set }
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
    
    public func getCachedImage(completion: @escaping ((_ image: UIImage?) -> Void)) {
        
        let modifier = AnyModifier { request in
            var r = request
            r.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 13_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "user-agent")
            // 支持 webp
            r.addValue("image/webp */*", forHTTPHeaderField: "Accept")
            return r
        }
        
        let options: [KingfisherOptionsInfoItem] = [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default),
            .requestModifier(modifier)
        ]
        
        if let dataProvider = imageDataProvider, isBase64Image {
            _ = KingfisherManager.shared.retrieveImage(with: .provider(dataProvider), options: options) { (result) in
                switch result {
                case .success(let resultValue):
                    completion(resultValue.image)
                case .failure(let error):
                    dPrint("---GetCachedImage; Base64URL: \(String(describing: self.imageURL)) Error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        } else if let url = imageURL {
            KingfisherManager.shared.retrieveImage(with: url, options: options) { (result) in
                switch result {
                case .success(let resultValue):
                    completion(resultValue.image)
                case .failure(let error):
                    dPrint("---GetCachedImage; URL: \(url) Error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        } else {
            completion(nil)
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
