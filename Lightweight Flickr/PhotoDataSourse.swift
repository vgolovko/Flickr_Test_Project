//
//  PhotoDataSourse.swift
//  Lightweight Flickr
//
//  Created by Vitaliy on 14.06.17.
//  Copyright © 2017 com.postindustria. All rights reserved.
//

import Foundation
import FlickrKitFramework
import CoreLocation

class PhotoDataSourse {
    var photos: [PhotoModel] = []
    var count: Int {
        return photos.count
    }
    var page: Int = 1
    var totalPage: Int?
    let itemsPerPage = 20
    var lastItemIndex: Int = 0

    func fetchPhoto(forSearch keyword: String = "", completionHandler:@escaping (_ success:Bool, _ error:Error?) -> Void) {
        /*
         "text" : "search_text"
         "lat" : ""
         "lon" : ""
         "radius" : ""
         "radius_units" : "km" - default
         "extras" : ""
         "per_page" : "owner_name, geo"
         "page" : ""
         let flickrInteresting = FKFlickrInterestingnessGetList()
         flickrInteresting.per_page = "15"
         flickrInteresting.page = "2"
         */
        let args:[String : String] = ["text" : keyword, "page" : "\(self.page)", "per_page" : "\(self.itemsPerPage)"]
        FlickrKit.shared().call("flickr.photos.search", args: args, completion: { (response, error) in
            DispatchQueue.main.async(execute: { () -> Void in
                if let response = response,
                    let photoArray = FlickrKit.shared().photoArray(fromResponse: response) {
                    var photos = response["photos"] as! [String : Any]
                    self.totalPage = photos["pages"] as? Int
                    for photoDictionary in photoArray {
                        if let model: PhotoModel = PhotoModel.init(withDictionaty: photoDictionary) {
                            self.photos.append(model)
                        }
                    }
                    
                    completionHandler(true, nil)
                } else {
                    if let error = error as NSError? {
                        ()
                        completionHandler(false, error)
                    }
                }
            })
        })
    }
    
    
    func fetchPhoto(_ coordinate:CLLocationCoordinate2D?, completionHandler:@escaping (_ success:Bool, _ error:Error?) -> Void) {
        if let coord = coordinate {
            let args:[String : String] = ["radius" : "1", "lat" : "\(coord.latitude)", "lon" : "\(coord.longitude)", "page" : "\(self.page)", "per_page" : "\(self.itemsPerPage)"]
            FlickrKit.shared().call("flickr.photos.getRecent", args: args, completion: { (response, error) in
                DispatchQueue.main.async(execute: { () -> Void in
                    if let response = response,
                        let photoArray = FlickrKit.shared().photoArray(fromResponse: response) {
                        var photos = response["photos"] as! [String : Any]
                        self.totalPage = photos["pages"] as? Int
                        for photoDictionary in photoArray {
                            if let model: PhotoModel = PhotoModel.init(withDictionaty: photoDictionary) {
                                self.photos.append(model)
                            }
                        }
                        
                        completionHandler(true, nil)
                    } else {
                        if let error = error as NSError? {
                            ()
                            completionHandler(false, error)
                        }
                    }
                })
            })
        }
    }
    
    func photoForItemAtIndexPath(_ indexPath: IndexPath) -> PhotoModel? {
        return self.photos[indexPath.item]
    }
    
    
    func indexPathForPhoto(_ photo:PhotoModel) -> IndexPath {
        var item = 0
        for (index, currentPhoto) in self.photos.enumerated()
        {
            if currentPhoto === photo
            {
                item = index
                break
            }
        }
        
        return IndexPath(item: item, section:0)
    }

}
