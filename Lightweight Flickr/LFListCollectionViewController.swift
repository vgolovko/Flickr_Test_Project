//
//  LFListCollectionViewController.swift
//  Lightweight Flickr
//
//  Created by Vitaliy on 07.06.17.
//  Copyright © 2017 com.postindustria. All rights reserved.
//

import UIKit
import CoreLocation
import FlickrKitFramework

private let reuseIdentifier = "ListCell"


class LFListCollectionViewController: UICollectionViewController {

    fileprivate let dataSourse = PhotoDataSourse()
    
    let loadingQueue = OperationQueue()
    fileprivate var loadingOperations = [IndexPath : ImageDowloader]()
    
    fileprivate var currentLocationCoordinate: CLLocationCoordinate2D?
    
    fileprivate lazy var locationMannager = CLLocationManager()
    
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = collectionView!.frame.width / 3
        let layout = collectionViewLayout as! LFListCollectionViewLayout
        layout.itemSize = CGSize(width: width, height: width)
        
        locationMannager.delegate = self
        locationMannager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationMannager.requestWhenInUseAuthorization()
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            if let controller = segue.destination as? LFDetailViewController {
                if let cell = sender as? LFListCollectionViewCell {
                    if let indexPath = self.collectionView?.indexPath(for: cell) {
                        controller.photoItem = dataSourse.photoForItemAtIndexPath(indexPath)
                    }
                }
            }
        }
    }
    
    
    func loadData() {
        let collerctionItemsCount = collectionView?.numberOfItems(inSection: 0)
        if (collerctionItemsCount != dataSourse.count) {
            
            var indexPaths: [IndexPath] = []
            for index in dataSourse.lastItemIndex..<dataSourse.lastItemIndex + dataSourse.itemsPerPage {
                indexPaths.append(IndexPath(item:index, section: 0))
            }
            
            dataSourse.lastItemIndex = dataSourse.lastItemIndex + dataSourse.itemsPerPage
            
            collectionView?.performBatchUpdates({
                self.collectionView?
                    .insertItems(at: indexPaths)
            }, completion: nil)
        }
    }

    
    func fetchFlickrImages() {
        self.dataSourse.fetchPhoto(self.currentLocationCoordinate!, completionHandler: { (success, error) in
//        self.dataSourse.fetchPhoto(forSearch: " ") { (success, error) in
            if success {
                self.loadData()
            } else {
                if let error = error as NSError? {
                    switch error.code {
                    case FKFlickrInterestingnessGetListError.serviceCurrentlyUnavailable.rawValue:
                        break;
                    default:
                        break;
                    }
                    
                    let alertController = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
        
         /*
         "text" : "search_text"
         "lat" : ""
         "lon" : ""
         "radius" : ""
         "radius_units" : "km" - default
         "extras" : ""
         "per_page" : "owner_name, geo"
         "page" : ""
         */
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(self.dataSourse.count)")
        return self.dataSourse.count
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LFListCollectionViewCell
    
        return cell
    }

    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.item == dataSourse.count - 1) {
            dataSourse.page += 1
            fetchFlickrImages()
        }
        
        guard let cell = cell as? LFListCollectionViewCell else { return }
        
        let updateCellClosure: (PhotoModel?) -> () = { [unowned self] (photoModel) in
            cell.updateAppearanceFor(photoModel, animated: true)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
    
        if let dataLoader = loadingOperations[indexPath] {
            if let thePhoto = dataLoader.photoModel {
                cell.updateAppearanceFor(thePhoto, animated: false)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            if let thePhoto = dataSourse.photoForItemAtIndexPath(indexPath) {
                thePhoto.fetchImageURL(.SmallSize)
                let dataLoader = ImageDowloader(thePhoto)
                dataLoader.loadingCompleteHandler = updateCellClosure
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
    
}


extension LFListCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = loadingOperations[indexPath] {
                return
            }
            
            if let thePhoto = self.dataSourse.photoForItemAtIndexPath(indexPath) {
                thePhoto.fetchImageURL(.SmallSize)
                let dataLoader = ImageDowloader(thePhoto)
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("Cancel Prefetch")
        for indexPath in indexPaths {
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
}


extension LFListCollectionViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationMannager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocationCoordinate = locations.last?.coordinate
        if currentLocationCoordinate != nil {
            locationMannager.stopUpdatingLocation()
            fetchFlickrImages()
        }
    }
}
