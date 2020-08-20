//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Renad nasser on 13/08/2020.
//  Copyright © 2020 Renad nasser. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotosViewController:UIViewController{
    
    // MARK: - Outlet
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    
    // MARK: - Proprites
    var flowLayout: UICollectionViewFlowLayout!
    
    var dataController:DataController!
    var pin:Pin!
    
    var fetchResultsController:NSFetchedResultsController<Photo>!
    
    /// has  images yet?
    var isEmpty: Bool{
        return fetchResultsController.fetchedObjects?.count == 0 ? true : false
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set collectionView proprites
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
        // Set Layout
        configureLayout()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpFetchedResultController()
        getPhotos()
        
        
        
        
        
    }
    //MARK: - UI Elements
    
    // Cell Layout Helper
    func configureLayout() {
        
        let numOfItemPerRow:CGFloat = 4
        let lineSpacing:CGFloat = 5
        let interItemSpacing:CGFloat = 5
        
        let width = (collectionView.frame.width - (numOfItemPerRow - 1) * interItemSpacing ) / numOfItemPerRow
        
        let height = width
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize=CGSize(width: width, height: height)
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.minimumInteritemSpacing = interItemSpacing
        
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
        
    }
    
    // SetUIElements
    func isLoading(_ loding:Bool) {
        //buttons enable
        newCollectionButton.isEnabled = !loding
        
    }
    
    
    
    //MARK: - Feach Request
    
    fileprivate func setUpFetchedResultController() {
        ///Get Photos
        ///step 1
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        ///step 2
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "Photos")
        /// step 3
        fetchResultsController.delegate = self
        ///step 4
        do{
            try fetchResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed :\(error.localizedDescription)")
        }
        
        self.save()
        
    }
    
    //MARK: - Reload Elements
    func getPhotos(){
        
        self.showSpinner()
        isLoading(true)
        
        if isEmpty {
            /// get photots from API
            FlickrAPI.requestURLImages(lat: pin.lat, long: pin.long) { (photosURL, error) in
                
                ///Error accure
                if error != nil {
                    ErrorHandller.showAlert(title: "", message: "please, try again by reload new collection.", viewController: self)
                }else{
                    ///No images found
                    if photosURL.count == 0 {
                        self.collectionView.setEmptyMessage("No photos.")
                        ErrorHandller.showAlert(title: "", message: "No imges found, please try again later.", viewController: self)
                    }else{
                        ///add images to core date
                        for url in photosURL{
                            self.getImageData(url)
                            
                        }
                        
                    }
                }
            }
            
        }
        
        ///set UI
        isLoading(false)
        PhotosViewController.removeSpinner()
        
        self.save()
        self.collectionView.reloadData()
        
    }
    //MARK: - New Collection Method
    
    @IBAction func reloadPhotos(_ sender: Any) {
        removeAllPhotos()
        getPhotos()
    }
    
    //MARK: - Core Data Methods
    
    //MARK: add Photo
    func addPhoto(url: String, data:Data) {
        let photo = Photo(context: dataController.viewContext)
        photo.creationDate = Date()
        photo.img = data
        photo.url = url
        photo.pin = pin
        
        self.save()
    }
    
    //MARK:  delete Photo
    func deletePhoto(_ photo: Photo) {
        dataController.viewContext.delete(photo)
        self.save()
        
    }
    //MARK: Remove all photos
    func removeAllPhotos() {
        if let photos = fetchResultsController.fetchedObjects {
            for photo in photos {
                dataController.viewContext.delete(photo)
                
                self.save()
            }
        }
    }
    //MARK: SAFE
    
    func save() {
        do {
            try dataController.viewContext.save()
        } catch {
            print("Error saving")
        }
    }
    
    
    
}
// MARK: - Collection View
extension PhotosViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    ///Num of items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchResultsController.fetchedObjects?.count ?? 0
    }
    
    
    ///set cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let aPhoto = fetchResultsController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! LocationPhotosCustomCell
        
        // Configure cell
        cell.activityIndicator.startAnimating()
        if let photoData = aPhoto.img {
            
            cell.imageView.image = UIImage(data: photoData)
        }
        cell.activityIndicator.isHidden = false
        cell.activityIndicator.stopAnimating()
        return cell
    }
    
    // Helper get image by url in data core
    func getImageData(_ urlString:String){
        
        //TODO:Call image
        FlickrAPI.downloadImage(Stringurl: urlString) { (data, error) in
            if let data = data{
                self.addPhoto(url: urlString, data: data)
            }else{
                print("No Data downloaded")
            }
        }
        
    }
    
    
    //MARK:  delete once click on photo
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let aPhoto = fetchResultsController.object(at: indexPath)
        deletePhoto(aPhoto)
    }
    
}

extension PhotosViewController: NSFetchedResultsControllerDelegate{
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        default: print("error accure")
        }
        collectionView.reloadData()
        
    }
}

//MARK: - UI Collection View extention

extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func deleteEmptyMessage() {
        self.backgroundView = nil
    }
}
