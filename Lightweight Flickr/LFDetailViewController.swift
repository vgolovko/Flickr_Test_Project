//
//  LFDetailViewController.swift
//  Lightweight Flickr
//
//  Created by Vitaliy on 21.06.17.
//  Copyright © 2017 com.postindustria. All rights reserved.
//

import UIKit

class LFDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageWidthConstrant: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var photoItem: PhotoModel?
    let loadingQueue = OperationQueue()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let photo = photoItem {
            photo.fetchImageURL(.OriginalSize)
            let dataLoader = ImageDowloader(photo)
            dataLoader.loadingCompleteHandler = { [unowned self] (photoModel) in
                DispatchQueue.main.async {
                    if let image = photoModel.image {
                        self.imageView.image = image
                        self.scrollView.contentSize = image.size
                        
                        self.imageWidthConstrant.constant = image.size.width
                        self.imageHeightConstraint.constant = image.size.height
                    }
                }
            }
            loadingQueue.addOperation(dataLoader)
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        loadingQueue.cancelAllOperations()
    }

    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        if let image = imageView.image {
            let widthScale = size.width / image.size.width
            let heightScale = size.height / image.size.height
            let minScale = min(widthScale, heightScale)
            
            scrollView.minimumZoomScale = minScale
            
            scrollView.zoomScale = minScale
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(view.bounds.size)
    }

}


extension LFDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
    }
    
}
