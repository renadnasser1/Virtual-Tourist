//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Renad nasser on 13/08/2020.
//  Copyright © 2020 Renad nasser. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class MapViewController:UIViewController,MKMapViewDelegate{
    //MARK: - Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Proprites
    ///Data Source
    var dataController:DataController!
    var fetchResultsController:NSFetchedResultsController<Pin>!
    
    //MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate=self
        
        setUI()
        setUpFetchedResultController()
        loadPins()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultsController = nil
    }
    //MARK: - UI
    func setUI() {
        ///Set duration of long press
        let longPressGus=UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        longPressGus.minimumPressDuration = 2.0
        //Add guster to map view
        mapView.addGestureRecognizer(longPressGus)
    }
    //MARK: - Core Data
    
    //MARK:  Feach Request
    fileprivate func setUpFetchedResultController() {
        ///Get pains
        ///step 1
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "lat", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        ///step 2
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "Pins")
        /// step 3
        fetchResultsController.delegate = self
        
        ///step 4
        do{
            try fetchResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed :\(error.localizedDescription)")
        }
        
        
    }
    
    //MARK: load pins on map
    func loadPins(){
        if let pins = getPains() {
            for location in pins{
                let coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
                
                //Create MKPointAnnotation
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    //MARK:  Get all Pins
    func getPains() -> [Pin]? {
        return fetchResultsController.fetchedObjects
    }
    
    //MARK: Remove all data stored in core data
    func removeAllData() {
        
        ///remove all photos
        let fetchPhotos = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchPhotos)
        
        do{
            try dataController.viewContext.execute(deleteRequest)
        }catch{
            print("error delete photos")
        }
        
        ///remove all pains
        let fetchPins = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let deleteRequestP = NSBatchDeleteRequest(fetchRequest: fetchPins)
        do{
            try dataController.viewContext.execute(deleteRequestP)
        }catch{
            print("error delete pins")
        }
        
        mapView.removeAnnotations(self.mapView.annotations)
        ///save changes
        do{
            try dataController.viewContext.save()
        }catch{
            print("error saving")
        }
        
        
    }
    
    //MARK: - Clear buttond tapped
    @IBAction func removeAllDataTapped(_ sender: Any) {
        presentAlert()
    }
    
    func presentAlert(){
        
        let alert = UIAlertController(title: "Remove all data", message: "are you sure you want to dalete all pins and thier photos", preferredStyle: .alert)
        
        // Create actions "Bottons"
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let sureAction = UIAlertAction(title: "Sure", style: .default) { action in
            self.removeAllData()
        }
        
        
        alert.addAction(cancelAction)
        alert.addAction(sureAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Map delagete
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            //            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    @objc func addAnnotation(press:UILongPressGestureRecognizer){
        if press.state == .began{
            ///get Location
            let locationOnMap = press.location(in: mapView)
            let coordinates = mapView.convert(locationOnMap, toCoordinateFrom: mapView)
            
            /// create pin with location
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            
            ///create location to store it in core data
            addToCoreData(annotation)
            
            //            ///add pin to the map
            mapView.addAnnotation(annotation)
            
        }
        
    }
    
    func addToCoreData(_ annotation:MKPointAnnotation){
        let location = Pin(context: dataController.viewContext)
        location.lat = annotation.coordinate.latitude
        location.long = annotation.coordinate.longitude
        ///Save note to prsistence store , in actual app must notfie the user
        do{
            try dataController.viewContext.save()
        } catch {
            ErrorHandller.showAlert(title: "", message: error.localizedDescription, viewController: self)
        }
    }
    
    //MARK: - Navigation
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        let photosVC = storyboard?.instantiateViewController(identifier: "PhotosViewController") as! PhotosViewController
        if let pins = getPains(){
            for pin in pins{
                
                if pin.lat == view.annotation?.coordinate.latitude,
                    pin.long == view.annotation?.coordinate.longitude{
                    
                    photosVC.pin = pin
                    photosVC.dataController = dataController
                    
                    self.navigationController?.pushViewController(photosVC, animated: true)
                    
                }
                
            }
        }
    }
}



extension MapViewController:NSFetchedResultsControllerDelegate{
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let point = anObject as? Pin else {
            preconditionFailure("All changes observed in the map view controller should be for Point instances")
        }
        
        switch type {
        case .insert:
            mapView.addAnnotation(point)
        default:
            print("How did we move a Point? We have a stable sort.")
        }
    }
    
}
