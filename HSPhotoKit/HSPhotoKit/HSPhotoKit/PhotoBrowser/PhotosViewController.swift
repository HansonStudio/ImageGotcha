//
//  HSPhotoKit
//
//  Created by Hanson on 2019/9/27.
//  Copyright © 2019 HansonStudio. All rights reserved.
//


import UIKit

public typealias PhotosViewControllerReferenceViewHandler = (_ photo: PhotoViewable) -> (UIView?)
public typealias PhotosViewControllerNavigateToPhotoHandler = (_ photo: PhotoViewable) -> ()
public typealias PhotosViewControllerDismissHandler = (_ viewController: PhotosViewController) -> ()
public typealias PhotosViewControllerLongPressHandler = (_ photo: PhotoViewable, _ gestureRecognizer: UILongPressGestureRecognizer?) -> ()
public typealias PhotosViewControllerActionButtonTapped = (_ photo: PhotoViewable) -> ()

public class PhotosViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    public var referenceViewForPhotoWhenDismissingHandler: PhotosViewControllerReferenceViewHandler?
    public var navigateToPhotoHandler: PhotosViewControllerNavigateToPhotoHandler?
    public var willDismissHandler: PhotosViewControllerDismissHandler?
    public var didDismissHandler: PhotosViewControllerDismissHandler?
    public var longPressGestureHandler: PhotosViewControllerLongPressHandler?
    public var actionButtonTappedHandler: PhotosViewControllerActionButtonTapped?
    
    var overlayView: PhotosOverlayView?
    var currentPhotoViewController: PhotoViewController? {
        return pageViewController.viewControllers?.first as? PhotoViewController
    }

    var currentPhoto: PhotoViewable? {
        return currentPhotoViewController?.photo
    }

    private(set) var pageViewController: UIPageViewController!
    private(set) var actionButtonStyle: ActionButtonStyle = .download
    private(set) var isHideURLTextView: Bool = false
    private(set) var dataSource: PhotosDataSource
    private(set) lazy var singleTapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(PhotosViewController.handleSingleTapGestureRecognizer(_:)))
    }()
    private(set) lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(PhotosViewController.handlePanGestureRecognizer(_:)))
        gesture.maximumNumberOfTouches = 1

        return gesture
    }()
    
    private var statusBarHidden = false
    private var shouldHandleLongPressGesture = false

    let photoTransitionDelegate = PhotoTransitionDelegate()
    
    
    // MARK: - Initialization
    
    public init(photos: [PhotoViewable], initialPhoto: PhotoViewable? = nil, referenceView: UIView? = nil, actionButtonStyle: ActionButtonStyle = .download, isHideURLTextView: Bool = false) {
        dataSource = PhotosDataSource(photos: photos)
        self.actionButtonStyle = actionButtonStyle
        self.isHideURLTextView = isHideURLTextView
        super.init(nibName: nil, bundle: nil)
        initialSetupWith(initialPhoto, referenceView)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        dataSource = PhotosDataSource(photos: [])
        super.init(nibName: nil, bundle: nil)
        initialSetupWith()
    }

    required public init?(coder aDecoder: NSCoder) {
        dataSource = PhotosDataSource(photos: [])
        super.init(nibName: nil, bundle: nil)
        initialSetupWith()
    }
    
    deinit {
        pageViewController.delegate = nil
        pageViewController.dataSource = nil
    }

    
    // MARK: - View Life Cycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = UIColor.white
        view.backgroundColor = UIColor.black
        navigationController?.navigationBar.isHidden = true
        pageViewController.view.backgroundColor = UIColor.clear
        
        pageViewController.view.addGestureRecognizer(panGestureRecognizer)
        pageViewController.view.addGestureRecognizer(singleTapGestureRecognizer)
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pageViewController.didMove(toParent: self)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.isHidden = true

    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        overlayView?.setHidden(false, animated: true)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !photoTransitionDelegate.interactiveDismissal {
            navigationController?.navigationBar.isHidden = false
        }
    }
    
    override public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        if presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
            return
        }
        var startingView: UIView?
        if currentPhotoViewController?.scalingImageView.imageView.image != nil {
            startingView = currentPhotoViewController?.scalingImageView.imageView
        }
        photoTransitionDelegate.transitionAnimator.startingView = startingView
        photoTransitionDelegate.transitionAnimator.photo = currentPhoto

        if let currentPhoto = currentPhoto {
            photoTransitionDelegate.transitionAnimator.endingView = referenceViewForPhotoWhenDismissingHandler?(currentPhoto)
        } else {
            photoTransitionDelegate.transitionAnimator.endingView = nil
        }

        let overlayWasHiddenBeforeTransition = overlayView?.isHidden ?? false
        overlayView?.setHidden(true, animated: true)

        willDismissHandler?(self)

        super.dismiss(animated: flag) { () -> Void in
            let isStillOnscreen = self.view.window != nil
            if isStillOnscreen && !overlayWasHiddenBeforeTransition {
                self.overlayView?.setHidden(false, animated: true)
            }

            if !isStillOnscreen {
                self.didDismissHandler?(self)
            }
            completion?()
        }
    }
    
    
    // MARK: - UIResponder
    
    override public func copy(_ sender: Any?) {
        UIPasteboard.general.image = currentPhoto?.image ?? currentPhotoViewController?.scalingImageView.image
    }
    
    override public var canBecomeFirstResponder: Bool {
        return true
    }
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let _ = currentPhoto?.image ?? currentPhotoViewController?.scalingImageView.image , shouldHandleLongPressGesture && action == #selector(NSObject.copy) {
            return true
        }
        return false
    }
    
    
    // MARK: - Status Bar
    
    override public var prefersStatusBarHidden: Bool {
        if let parentStatusBarHidden = presentingViewController?.prefersStatusBarHidden , parentStatusBarHidden == true {
            return parentStatusBarHidden
        }
        return statusBarHidden
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
}


// MARK: - Function

extension PhotosViewController {
    private func initialSetupWith(_ initialPhoto: PhotoViewable? = nil, _ referenceView: UIView? = nil) {
        if let photo = initialPhoto, dataSource.containsPhoto(photo) {
            setUpPageViewController(photo)
            setUpTransition(startingView: referenceView, startingPhoto: photo)
            
        } else if let photo = dataSource.photos.first {
            setUpPageViewController(photo)
            setUpTransition(startingView: referenceView, startingPhoto: photo)
        }
        
        setupOverlayView()
    }
    
    private func setUpPageViewController(_ photo: PhotoViewable) {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: 16.0])
        pageViewController.view.backgroundColor = UIColor.clear
        pageViewController.delegate = self
        pageViewController.dataSource = self
        let photoViewController = initializePhotoViewControllerForPhoto(photo)
        pageViewController.setViewControllers([photoViewController], direction: .forward, animated: false, completion: nil)
        
        addBlurBackground()
        
        updateCurrentPhotosInformation()
    }
    
    private func setUpTransition(startingView: UIView?, startingPhoto: PhotoViewable?) {
        photoTransitionDelegate.transitionAnimator.startingView = startingView
        photoTransitionDelegate.transitionAnimator.photo = startingPhoto
        photoTransitionDelegate.transitionAnimator.endingView = currentPhotoViewController?.scalingImageView.imageView
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = photoTransitionDelegate
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    private func updateCurrentPhotosInformation() {
        if let currentPhoto = currentPhoto {
            overlayView?.populateWithPhoto(currentPhoto)
        }
    }

    private func setupOverlayView() {
        overlayView = PhotosOverlayView(frame: CGRect.zero)
        overlayView?.urlTextView.isHidden = isHideURLTextView
        overlayView?.actionButtonStyle = actionButtonStyle
        overlayView?.photosViewController = self
        
        updateCurrentPhotosInformation()
        
        overlayView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView?.frame = view.bounds
        view.addSubview(overlayView!)
        overlayView?.setHidden(true, animated: false)
        overlayView?.actionButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
    }
    
    private func initializePhotoViewControllerForPhoto(_ photo: PhotoViewable) -> PhotoViewController {
        let photoViewController = PhotoViewController(photo: photo)
        singleTapGestureRecognizer.require(toFail: photoViewController.doubleTapGestureRecognizer)
        photoViewController.longPressGestureHandler = { [weak self] gesture in
            guard let longPressGestureHandler = self?.longPressGestureHandler else { return }
            longPressGestureHandler(photo, gesture)
        }
        return photoViewController
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Photo Save Fail!!", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "", message: "Photo Saved", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    func addBlurBackground() {
        let backgroundView = UIView()
        backgroundView.frame = view.bounds
        backgroundView.backgroundColor = UIColor.gray
        let blurContentView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurContentView.frame = backgroundView.bounds
        blurContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(backgroundView, at: 0)
        backgroundView.addSubview(blurContentView)
    }
    
    @objc private func downloadButtonTapped(sender: UIButton) {
        if let currentPhoto = currentPhoto {
            guard let downloadButtonTappedHandler = self.actionButtonTappedHandler else { return }
            downloadButtonTappedHandler(currentPhoto)
        }
    }
}


// MARK: - Gesture Recognizers

extension PhotosViewController {
    @objc private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            photoTransitionDelegate.interactiveDismissal = true
            dismiss(animated: true, completion: nil)
        } else {
            photoTransitionDelegate.interactiveDismissal = gestureRecognizer.state != .ended
            photoTransitionDelegate.interactiveAnimator.handlePanWithPanGestureRecognizer(gestureRecognizer, viewToPan: pageViewController.view, anchorPoint: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
        }
    }
    
    @objc private func handleSingleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
//        guard let overlayView = overlayView else { return }
//        overlayView.setHidden(!overlayView.isHidden, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UIPageViewControllerDataSource / UIPageViewControllerDelegate

extension PhotosViewController {
    
    @objc public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let photoViewController = viewController as? PhotoViewController,
            let photoIndex = dataSource.indexOfPhoto(photoViewController.photo),
            let newPhoto = dataSource[photoIndex-1] else {
                return nil
        }
        return initializePhotoViewControllerForPhoto(newPhoto)
    }
    
    @objc public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let photoViewController = viewController as? PhotoViewController,
            let photoIndex = dataSource.indexOfPhoto(photoViewController.photo),
            let newPhoto = dataSource[photoIndex+1] else {
                return nil
        }
        return initializePhotoViewControllerForPhoto(newPhoto)
    }
    
    @objc public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            updateCurrentPhotosInformation()
            if let currentPhotoViewController = currentPhotoViewController {
                navigateToPhotoHandler?(currentPhotoViewController.photo)
            }
        }
    }
}
