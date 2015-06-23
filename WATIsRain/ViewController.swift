//
//  ViewController.swift
//  WATIsRain
//
//  Created by Anish Chopra on 2015-06-21.
//  Copyright (c) 2015 Anish Chopra. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    // This is the map view that is shows on Main.storyboard
    @IBOutlet weak var campusMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set initial location to show entire campus
        let campusLocation = CLLocationCoordinate2D(latitude: 43.472285, longitude: -80.544858)
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let region = MKCoordinateRegion(center: campusLocation, span: span)
        self.campusMapView.region = region
        
        self.campusMapView.delegate = self
        
        // Use openstreetmap tiles instead of apple maps tiles
        let overlayPath = "http://c.tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(URLTemplate: overlayPath)
        overlay.canReplaceMapContent = true // don't bother loading Apple Maps
        self.campusMapView.addOverlay(overlay)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This function is needed for the MKMapViewDelegate protocol
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKTileOverlay {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        return nil
    }


}

