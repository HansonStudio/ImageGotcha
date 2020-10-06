//
//  Kingfisher+Extenstion.swift
//  HSPhotoKit
//
//  Created by Hanson on 2020/5/24.
//

import Kingfisher
import KingfisherWebP

extension KingfisherWrapper where Base: KFCrossPlatformImageView {
    
    public func setImage(with photo: Photo, size: CGSize? = nil, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        
        let modifier = AnyModifier { request in
            var r = request
            r.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 13_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "user-agent")
            // 支持 webp
            r.addValue("image/webp */*", forHTTPHeaderField: "Accept")
            return r
        }
        
        var options: [KingfisherOptionsInfoItem] = [
            .transition(.fade(0.2)),
            .requestModifier(modifier)
        ]
        var processor: ImageProcessor = WebPProcessor.default
        if let size = size {
            processor = processor |> DownsamplingImageProcessor(size: size)
        }
        let samplingImageOptions: [KingfisherOptionsInfoItem] = [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage,
            .cacheSerializer(WebPSerializer.default)
        ]
        options.append(contentsOf: samplingImageOptions)
        
        if let dataProvider = photo.imageDataProvider, photo.isBase64Image {
            setImage(with: dataProvider, options: options, completionHandler:  { result in
                completionHandler?(result)
                #if DEBUG
                switch result {
                case .success(let resultValue):
                    print("---图片加载成功(Base64), CacheType: \(resultValue.cacheType), Source: \(resultValue.source)")
                case .failure(let error):
                    print("---加载图片出错(Base64)：\(error.localizedDescription)")
                }
                #endif
            })
        } else if let url = photo.imageURL {
            setImage(with: url, options: options, completionHandler:  { result in
                completionHandler?(result)
                #if DEBUG
                switch result {
                case .success(let resultValue):
                    print("---图片加载成功(URL), CacheType: \(resultValue.cacheType), Source: \(resultValue.source)")
                    break
                case .failure(let error):
                    print("---加载图片出错(URL)：\(error.localizedDescription)")
                    break
                }
                #endif
            })
        }
    }
}
