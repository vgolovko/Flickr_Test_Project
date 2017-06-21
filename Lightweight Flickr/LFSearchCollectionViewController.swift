//
//  LFSearchCollectionViewController.swift
//  Lightweight Flickr
//
//  Created by Vitaliy on 07.06.17.
//  Copyright © 2017 com.postindustria. All rights reserved.
//

import UIKit
import FlickrKitFramework

private let reuseIdentifier = "SearchCell"

class LFSearchCollectionViewController: UICollectionViewController {
    
    fileprivate let dataSourse = PhotoDataSourse()
    
    var searchKey: String?
    
    let loadingQueue = OperationQueue()
    fileprivate var loadingOperations = [IndexPath : ImageDowloader]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            if let controller = segue.destination as? LFDetailViewController {
                if let cell = sender as? LFSearchCollectionViewCell {
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
        if let search = searchKey {
            self.dataSourse.fetchPhoto(forSearch: search) { (success, error) in
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
            }
        }
        
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
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(self.dataSourse.count)")
        return self.dataSourse.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LFSearchCollectionViewCell
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.item == dataSourse.count - 1) {
            dataSourse.page += 1
            fetchFlickrImages()
        }
        
        guard let cell = cell as? LFSearchCollectionViewCell else { return }
        
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
                thePhoto.fetchImageURL(.LargeSize)
                let dataLoader = ImageDowloader(thePhoto)
                dataLoader.loadingCompleteHandler = updateCellClosure
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView: LFSearchCollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SearchHeader", for: indexPath) as! LFSearchCollectionReusableView
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
    
}


extension LFSearchCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = loadingOperations[indexPath] {
                return
            }
            
            if let thePhoto = self.dataSourse.photoForItemAtIndexPath(indexPath) {
                thePhoto.fetchImageURL(.LargeSize)
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


extension LFSearchCollectionViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchKey = searchBar.text
        searchBar.resignFirstResponder()
        self.fetchFlickrImages()
    }
}

