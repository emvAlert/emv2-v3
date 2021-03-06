//
//  ViewController.swift
//  emv2
//
//  Created by Roen Wainscoat on 10/19/17.
//  Copyright © 2017 Roen Wainscoat. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var lat: String?
    var lon: String?
    var distance: Double?
    let locationManager = CLLocationManager()
    @IBOutlet weak var myLatitude: UITextField!
    @IBOutlet weak var myLongitude: UITextField!
    @IBOutlet weak var evLatitude: UITextField!
    @IBOutlet weak var evLongitude: UITextField!
    @IBOutlet weak var evDistance: UITextField!
    @IBOutlet weak var TARView: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTARStatusFalse()
        TARView.text = String("disabled")
        locationManager.delegate  = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        evLoad()
        // Do any additional setup after loading the view, typically from a nib.
}
    
    var TARStatus = false
    
    func setTARStatusFalse() {
        // Set TAR to false
        TARStatus = false
        print("TAR Status set to false")
    }
    
    func setTARStatusTrue() {
        // Set TAR to true
        TARStatus = true
        print("TAR Status set to true")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("GPS allowed.")
        }
        else {
            print("GPS not allowed.")
            return
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let myCoordinate = locationManager.location?.coordinate
        altitude = locationManager.location?.altitude
        latitude = myCoordinate?.latitude
        longitude = myCoordinate?.longitude
        
        myLatitude.text = String(latitude!)
        myLongitude.text = String(longitude!)
    }
    
    func evLoad() {
        super.viewDidLoad()
        fetchURL()
       // performSelector(inBackground: #selector(fetchURL), with: nil)
    }
    
    var evLocDidRefresh = false
    
    @objc func fetchURL() {
        var data = "00 A 0.0 0.0"
        if let url = URL(string: "https://roen.us/wapps/dev/evn/evn.txt") {
            do {
                data = "7 A 7.0 7.0"
                let data = try String(contentsOf: url)
                let allEvData = data.components(separatedBy: " ")
                evLatitude.text = allEvData[2]
                evLongitude.text = allEvData[3]
                evDistance.text = "33"
                evLocDidRefresh = true
            } catch {
                // error loading
                data = "9 A 9.0 9.0"
                let data = data.components(separatedBy: " ")
                evLatitude.text = data[1]
                evLongitude.text = data[2]
            }
        } else {
            // url bad
            data = "4 A 4.0 4.0"
        }
//        data = "2 A 2.0 2.0"
    }
    
    @IBAction func evRefresh(_ sender: UIButton) {
        evLoad()
        print("Refresh queued")
        sleep(1)
        if evLocDidRefresh == true {
            print("Refreshed from source")
            evLocDidRefresh = false
        } else {
            print("There was an error refreshing EVInfo from source. Please try again!")
        }
    }
    
    @IBAction func TAR(_ sender: Any) {
        if TARStatus == false {
            setTARStatusTrue()
            refreshEvArStatus()
        }
    }
    
    
    var evArLoop = false
    
    func refreshEvArStatus() {
        if TARStatus == false {
            evArLoop = false
            startEvAr()
            // EVAR will only start when the variable is set to true
            // EVAR will stop when the startEvAr is called and evArLoop is set to false because whenever the function is called, it checks the status of the variable.
            // refreshEvArStatus just sets the conditions for startEvAr to run, and ensures variables are not mixed. This function is not necessary but will help with eliminating crossreferencing variables merging.
        } else {
            evArLoop = true
            startEvAr()
            // EVAR will start because the variable is true AND the function to check the status of it and do appropriate actions is called.
        }
    }

    
    func startEvAr() {
        var rR = 0
        while evArLoop == true {
            fetchURL()
            if evLocDidRefresh == true {
                print("EVAR success!")
                // Private variable
                rR = rR++
                print(rR)
            }
            sleep(6)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

