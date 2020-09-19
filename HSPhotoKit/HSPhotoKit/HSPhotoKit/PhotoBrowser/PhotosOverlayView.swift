//
//  HSPhotoKit
//
//  Created by Hanson on 2018/5/8.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//


import UIKit

public enum ActionButtonStyle {
    case download
    case share
}

class PhotosOverlayView: UIView {
    
    var actionButtonStyle: ActionButtonStyle = .download {
        didSet {
            switch actionButtonStyle {
            case .download:
                actionButton.setBackgroundImage(UIImage(systemName: "tray.and.arrow.down"), for: .normal)
            case .share:
                actionButton.setBackgroundImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
            }
        }
    }
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(named: "photo_dismiss", in: Bundle(for: type(of: self)), compatibleWith: nil)
        button.setBackgroundImage(buttonImage, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 21)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "tray.and.arrow.down"), for: .normal)
        return button
    }()
    
    lazy var urlTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = true
        textView.showsHorizontalScrollIndicator = false
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.dataDetectorTypes = [.link]
        textView.textAlignment = .left
        textView.textColor = UIColor.white
        return textView
    }()
    
    weak var photosViewController: PhotosViewController?
    private var currentPhoto: PhotoViewable?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Pass the touches down to other views
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) , hitView != self {
            return hitView
        }
        return nil
    }

    @objc private func closeButtonTapped(sender: UIButton) {
        photosViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func setUpView() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)
        let topConstraint = NSLayoutConstraint(item: closeButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .topMargin, multiplier: 1.0, constant: 10.0)
        let widthConstraint = NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 84)
        let heightConstraint = NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 30)
        let rightPositionConstraint = NSLayoutConstraint(item: closeButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -10.0)
        self.addConstraints([topConstraint, widthConstraint, heightConstraint, rightPositionConstraint])
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(actionButton)
        let bottomConstraint = NSLayoutConstraint(item: actionButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottomMargin, multiplier: 1.0, constant: -20.0)
        let centerXConstraint = NSLayoutConstraint(item: actionButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        let actionBtnWidthConstraint = NSLayoutConstraint(item: actionButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 35)
        let actionBtnHeightConstraint = NSLayoutConstraint(item: actionButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 35)
        self.addConstraints([bottomConstraint, centerXConstraint, actionBtnWidthConstraint, actionBtnHeightConstraint])
        
        urlTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(urlTextView)
        let urlTextViewBottom = urlTextView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -15)
        let urlTextViewLeading = urlTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10)
        let urlTextViewTrailing = urlTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10)
        let urlTextViewHeight = urlTextView.heightAnchor.constraint(equalToConstant: 50)
        NSLayoutConstraint.activate([urlTextViewBottom, urlTextViewLeading, urlTextViewTrailing, urlTextViewHeight])
    }

}

extension PhotosOverlayView {
    func setHidden(_ hidden: Bool, animated: Bool) {
        if self.isHidden == hidden {
            return
        }
        if animated {
            self.isHidden = false
            self.alpha = hidden ? 1.0 : 0.0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction], animations: { () -> Void in
                self.alpha = hidden ? 0.0 : 1.0
            }, completion: { result in
                self.alpha = 1.0
                self.isHidden = hidden
            })
        } else {
            self.isHidden = hidden
        }
    }

    func populateWithPhoto(_ photo: PhotoViewable) {
        self.currentPhoto = photo
        guard let photosViewController = photosViewController else { return }
        guard let index = photosViewController.dataSource.indexOfPhoto(photo) else { return }
        let indexString = "\(index + 1)/\(photosViewController.dataSource.numberOfPhotos)"
        let title = NSAttributedString(string: indexString, attributes: [
                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                        NSAttributedString.Key.foregroundColor: UIColor.white])
        closeButton.setAttributedTitle(title, for: .normal)
        urlTextView.text = photo.imageURL?.absoluteString ?? ""
    }
}

