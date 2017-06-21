//
//  LFSearchCollectionViewCell.swift
//  Lightweight Flickr
//
//  Created by Vitaliy on 15.06.17.
//  Copyright © 2017 com.postindustria. All rights reserved.
//

import UIKit

class LFSearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photoModel: PhotoModel?
    
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
            self.titleLabel.text = photo.title
            self.ownerLabel.text = photo.owner
            activityIndicator?.alpha = 0
            activityIndicator?.stopAnimating()
        } else {
            activityIndicator?.alpha = 1.0
            activityIndicator?.startAnimating()
        }
    }
    
}
