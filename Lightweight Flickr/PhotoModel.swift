//
//  PhotoModel.swift
//  Lightweight Flickr
//
//  Created by Vitaliy on 14.06.17.
//  Copyright © 2017 com.postindustria. All rights reserved.
//

import UIKit
import FlickrKitFramework

enum ImageSize: UInt {
    case SmallSize, LargeSize, OriginalSize
}

class PhotoModel {
    
    var photoId: String?
    var title: String?
    var owner: String?
    var photoURL: URL?
    var image: UIImage?
    
    private var _flickrDict:[String : Any]
    
    required init?(withDictionaty flickrDict:[String : Any]) {
        if let photoId = flickrDict["id"] as? String,
            let title = flickrDict["title"] as? String,
            let owner = flickrDict["owner"] as? String
        {
        self.photoId = photoId
        self.title = title
        self.owner = owner
        self._flickrDict = flickrDict
        } else {
            return nil
        }
    }
    
    func fetchImageURL(_ imageSize:ImageSize) {
        switch imageSize {
        case .SmallSize:
            self.photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.largeSquare150, fromPhotoDictionary: _flickrDict)
        case .LargeSize:
            self.photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small320, fromPhotoDictionary: _flickrDict)
        case .OriginalSize:
            self.photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.large1024, fromPhotoDictionary: _flickrDict)
        }
    }
    
}
