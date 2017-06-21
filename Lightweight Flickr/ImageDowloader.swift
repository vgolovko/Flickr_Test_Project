//
//  ImageDowloader.swift
//  Lightweight Flickr
//
//  Created by Vitaliy on 14.06.17.
//  Copyright © 2017 com.postindustria. All rights reserved.
//

import UIKit

class ImageDowloader: Operation {

    var photoModel: PhotoModel?
    var loadingCompleteHandler: ((PhotoModel) -> ())?
    
    fileprivate let _photoModel: PhotoModel
    
    init(_ photoModel: PhotoModel) {
        _photoModel = photoModel
    }
    
    override func main() {
        if isCancelled { return }
        
        if let photoURL = _photoModel.photoURL {
            if let data = NSData(contentsOf :photoURL) {
                if let image = UIImage(data: data as Data) {
                    self.photoModel = _photoModel
                    self.photoModel?.image = image
                    loadingCompleteHandler?(self.photoModel!)
                }
            }
        }
    }
}
