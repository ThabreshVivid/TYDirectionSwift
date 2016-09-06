//
//  ViewController.swift
//  TYDirectionSwift
//
//  Created by Thabresh on 9/6/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController,UITextFieldDelegate {
    var mapManager = DirectionManager()
    var tableData = NSDictionary()
    var polyline: MKPolyline = MKPolyline()
    let GoogleMapsAPIServerKey = "AIzaSyDchKp5BlxpFd_NOZVI7HgjvzHHm_vkhH0"
    @IBOutlet weak var drawMap: MKMapView!
    @IBOutlet weak var txtTo: UITextField!
    @IBOutlet weak var txtFrom: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField .resignFirstResponder()
        let controller = GooglePlacesSearchController(
            apiKey: GoogleMapsAPIServerKey,
            placeType: PlaceType.Address
        )
        if textField.tag == 0 {
            controller.didSelectGooglePlace { (place) -> Void in
                print(place.description)
                self.txtFrom.text = place.name
                //Dismiss Search
                controller.active = false
            }
        }else{
            controller.didSelectGooglePlace { (place) -> Void in
                print(place.description)
                self.txtTo.text = place.name
                //Dismiss Search
                controller.active = false
            }
        }
         presentViewController(controller, animated: true, completion: nil)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 5            
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
    func removeAllPlacemarkFromMap(shouldRemoveUserLocation shouldRemoveUserLocation:Bool){
        if let mapView = self.drawMap {
            for annotation in mapView.annotations{
                if shouldRemoveUserLocation {
                    if annotation as? MKUserLocation !=  mapView.userLocation {
                        mapView.removeAnnotation(annotation as MKAnnotation)
                    }
                }
                let overlays = mapView.overlays
                mapView.removeOverlays(overlays)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickToGetDirection(sender: AnyObject) {
        if self.tableData.count > 0 {
            self .performSegueWithIdentifier("direction", sender: self)
            //self.directionTbl.hidden = false;
        }
    }
    @IBAction func ClickToGo(sender: AnyObject) {
        if isValidPincode() {
            mapManager.directionsUsingGoogle(from: txtFrom.text!, to: txtTo.text!) { (route,directionInformation, boundingRegion, error) -> () in
                
                if(error != nil){
                    print(error)
                }
                else{
                    let pointOfOrigin = MKPointAnnotation()
                    pointOfOrigin.coordinate = route!.coordinate
                    pointOfOrigin.title = directionInformation?.objectForKey("start_address") as! NSString as String
                    pointOfOrigin.subtitle = directionInformation?.objectForKey("duration") as! NSString as String
                    
                    let pointOfDestination = MKPointAnnotation()
                    pointOfDestination.coordinate = route!.coordinate
                    pointOfDestination.title = directionInformation?.objectForKey("end_address") as! NSString as String
                    pointOfDestination.subtitle = directionInformation?.objectForKey("distance") as! NSString as String
                    
                    let start_location = directionInformation?.objectForKey("start_location") as! NSDictionary
                    let originLat = start_location.objectForKey("lat")?.doubleValue
                    let originLng = start_location.objectForKey("lng")?.doubleValue
                    
                    let end_location = directionInformation?.objectForKey("end_location") as! NSDictionary
                    let destLat = end_location.objectForKey("lat")?.doubleValue
                    let destLng = end_location.objectForKey("lng")?.doubleValue
                    
                    let coordOrigin = CLLocationCoordinate2D(latitude: originLat!, longitude: originLng!)
                    let coordDesitination = CLLocationCoordinate2D(latitude: destLat!, longitude: destLng!)
                    
                    pointOfOrigin.coordinate = coordOrigin
                    pointOfDestination.coordinate = coordDesitination
                    if let web = self.drawMap {
                        dispatch_async(dispatch_get_main_queue()) {
                        self.removeAllPlacemarkFromMap(shouldRemoveUserLocation: true)
                        web.addOverlay(route!)
                        web.addAnnotation(pointOfOrigin)
                        web.addAnnotation(pointOfDestination)
                        web.setVisibleMapRect(boundingRegion!, animated: true)
                        print(directionInformation)
                        self.tableData = directionInformation!
                        }
                    }
                }
            } }
    }
    
     func isValidPincode() -> Bool {
        if txtFrom.text?.characters.count == 0
        {
            self .showAlert("Please enter your source address")
            return false
        }else if txtTo.text?.characters.count == 0
        {
            self .showAlert("Please enter your destination address")
            return false
        }
        return true
    }
    func showAlert(value:NSString)
    {
        let alert = UIAlertController(title: "Please enter your source address", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let viewController: DirectionDetail = segue.destinationViewController as? DirectionDetail {
            viewController.directionInfo = self.tableData
        }
        
     
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

