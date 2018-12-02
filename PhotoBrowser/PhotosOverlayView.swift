

import UIKit

class PhotosOverlayView: UIView {
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(named: "photo_dismiss", in: Bundle(for: type(of: self)), compatibleWith: nil)
        button.setBackgroundImage(buttonImage, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 21)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var downLoadButton: UIButton = {
        let frameworkBundle = Bundle(for: type(of: self))
        let button = UIButton()
        let buttonImage = UIImage(named: "download", in: Bundle(for: type(of: self)), compatibleWith: nil)
        button.setBackgroundImage(buttonImage, for: .normal)
        return button
    }()
    
    weak var photosViewController: PhotosViewController?
    private var currentPhoto: PhotoViewable?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpButton()
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

        if let photosViewController = photosViewController {
            if let index = photosViewController.dataSource.indexOfPhoto(photo) {
                let indexString = "\(index+1)/\(photosViewController.dataSource.numberOfPhotos)"
                let title = NSAttributedString(string: indexString,
                                               attributes: [
                                                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15),
                                                NSAttributedStringKey.foregroundColor: UIColor.white])
                closeButton.setAttributedTitle(title, for: .normal)
            }
        }
    }

    @objc private func closeButtonTapped(sender: UIButton) {
        photosViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func setUpButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(closeButton)
        let topConstraint = NSLayoutConstraint(item: closeButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .topMargin, multiplier: 1.0, constant: 10.0)
        let widthConstraint = NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 84)
        let heightConstraint = NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 30)
        let rightPositionConstraint = NSLayoutConstraint(item: closeButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -10.0)
        self.addConstraints([topConstraint, widthConstraint, heightConstraint, rightPositionConstraint])
        
        downLoadButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(downLoadButton)
        let bottomConstraint = NSLayoutConstraint(item: downLoadButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottomMargin, multiplier: 1.0, constant: -20.0)
        let centerXConstraint = NSLayoutConstraint(item: downLoadButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        self.addConstraints([bottomConstraint, centerXConstraint])
    }

}






