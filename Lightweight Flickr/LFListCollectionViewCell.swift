//
//  LFListCollectionViewCell.swift
//  Lightweight Flickr
//
//  Created by Vitaliy on 08.06.17.
//  Copyright © 2017 com.postindustria. All rights reserved.
//

import UIKit

class LFListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photoModel: PhotoModel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.photoImageView.image = nil
    }
    
    
    func updateAppearanceFor(_ photoModel:PhotoModel?, animated:Bool = true) {
        DispatchQueue.main.async {
            if animated {
                UIView.animate(withDuration: 0.5) {
                    self.displayNationalPark(photoModel)
                }
            } else {
                self.displayNationalPark(photoModel)
            }
        }
    }
    
    func displayNationalPark(_ photoModel: PhotoModel?) {
        self.photoModel = photoModel
        
        if let photo = photoModel {
            self.photoImageView.image = photo.image
            activityIndicator?.alpha = 0
            activityIndicator?.stopAnimating()
        } else {
            activityIndicator?.alpha = 1.0
            activityIndicator?.startAnimating()
        }
    }
    
}
