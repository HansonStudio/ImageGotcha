


import UIKit

class PhotoViewController: UIViewController, UIScrollViewDelegate {
    var photo: PhotoViewable
    
    var longPressGestureHandler: ((UILongPressGestureRecognizer) -> ())?
    
    lazy private(set) var scalingImageView: ScalingImageView = {
        return ScalingImageView()
    }()
    
    lazy private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PhotoViewController.handleDoubleTapWithGestureRecognizer(_:)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    lazy private(set) var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(PhotoViewController.handleLongPressWithGestureRecognizer(_:)))
        return gesture
    }()
    
    lazy private(set) var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    public init(photo: PhotoViewable) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scalingImageView.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scalingImageView.delegate = self
        scalingImageView.frame = view.bounds
        scalingImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scalingImageView)
        
        view.addSubview(activityIndicator)
        activityIndicator.center = scalingImageView.center
        activityIndicator.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        activityIndicator.sizeToFit()
        
        view.addGestureRecognizer(doubleTapGestureRecognizer)
        view.addGestureRecognizer(longPressGestureRecognizer)
        
        if let image = photo.image {
            self.scalingImageView.image = image
            self.activityIndicator.stopAnimating()
        } else if let thumbnailImage = photo.thumbnailImage {
            self.scalingImageView.image = thumbnailImage
            self.activityIndicator.stopAnimating()
            loadFullSizeImage()
        } else {
            if let fullImage = photo.getCachedImage(photo.imageURL) {
                self.activityIndicator.stopAnimating()
                scalingImageView.image = fullImage
            } else if let thumbnailImage = photo.getCachedImage(photo.thumbnailImageURL) {

                self.activityIndicator.stopAnimating()
                scalingImageView.image = thumbnailImage

                loadFullSizeImage()
            } else {
                activityIndicator.startAnimating()
                loadFullSizeImage()
            }
        }
    }

    private func loadFullSizeImage() {
        view.bringSubview(toFront: activityIndicator)
        self.photo.loadImageWithCompletionHandler({ [weak self] (image, error) -> () in
            let completeLoading = {
                self?.activityIndicator.stopAnimating()
                self?.scalingImageView.setImage(image, animated: true)
            }

            if Thread.isMainThread {
                completeLoading()
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    completeLoading()
                })
            }
        })
    }


    @objc private func handleLongPressWithGestureRecognizer(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            longPressGestureHandler?(recognizer)
        }
    }
    
    @objc private func handleDoubleTapWithGestureRecognizer(_ gesture: UITapGestureRecognizer) {
        guard scalingImageView.imageView.image != nil else { return }

        if scalingImageView.zoomScale <= 1 {
            let x = gesture.location(in: view).x + scalingImageView.contentOffset.x
            let y = gesture.location(in: view).y + scalingImageView.contentOffset.y
            let zoomRect = CGRect(x: x, y: y, width: 0, height: 0)
            scalingImageView.zoom(to: zoomRect, animated: true)
        } else {
            scalingImageView.setZoomScale(1, animated: true)
        }
    }

    fileprivate func getActualCenter(_ scrollView: UIScrollView) -> CGPoint {
        let offsetX = scalingImageView.bounds.width > scalingImageView.contentSize.width ?
            (scalingImageView.bounds.width - scalingImageView.contentSize.width) * 0.5 : 0.0
        let offsetY = scalingImageView.bounds.height > scalingImageView.contentSize.height ?
            (scalingImageView.bounds.height - scalingImageView.contentSize.height) * 0.5 : 0.0
        let actualCenter = CGPoint(x: scalingImageView.contentSize.width * 0.5 + offsetX,
                                   y: scalingImageView.contentSize.height * 0.5 + offsetY)

        return actualCenter
    }
    
    // MARK:- UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scalingImageView.imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scalingImageView.imageView.center = getActualCenter(scrollView)
    }

}
