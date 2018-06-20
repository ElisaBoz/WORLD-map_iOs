//
//  ViewController.swift
//  test
//
//  Created by Elisa on 18/06/2018.
//  Copyright © 2018 Elisa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
//import Alamofire

//struct ISOClass: Decodable {
//    let documentation: String
//    let results : [ResultsClass]
//
//    struct ResultsClass: Decodable {
//        let component: Component
//
//        struct Component: Decodable {
//            let _type: String
//            let city: String
//            let country: String
//            let country_code: String
//
//        }
//    }
//}

struct GroceryStore {
    //var documentation: String
    var component: [Component]
    
    struct Component: Codable {
        var _type: String
        var city: String
        var country: String
        var country_code: String
        
    }
}
let json = """
[
    {
        "name": "Home Town Market",
        "results": [
            {
                "name": "Produce",
                "components": {
                    "country_code": "AZE"
                },
                "shelves": [
                    {
                        "name": "Discount Produce",
                        "product": {
                            "name": "Banana",
                            "points": 200,
                            "description": "A banana that's perfectly ripe."
                        }
                    }
                ]
            }
        ]
    }
]
""".data(using: .utf8)!

struct GroceryStoreService: Decodable {
    //let documentation: String
    let results: [Aisle]
    
    struct Aisle: Decodable {
        let components: GroceryStore.Component
        
    }
}

extension GroceryStore {
    init(from service: GroceryStoreService) {
        component = []
        for aisle in service.results {
            component.append(aisle.components)
        }
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var MyMap: MKMapView!
    let manager = CLLocationManager()
    
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var urlGeo: UILabel!

    struct Article: Codable {
        let title: String
        let description: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // print(locations)
        
        let location = locations[0]
        let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        
       
        
        latitude.text = "Latitude : \(lat)"
        longitude.text = "Longitude : \(long)"
        
        let json2 = "https://api.opencagedata.com/geocode/v1/json?q=\(lat)9%2C%20\(long)&key=3cb5d4185cb14bbc93797e291549a2c7&language=fr&pretty=1"
        guard let url = URL(string: json2) else {return}
        URLSession.shared.dataTask(with: url) {(data,response, err) in
            guard let data = data else {return}
            
            do {
//                let IISO = try JSONDecoder().decode(ISOClass.self, from: data)

                let decoder = JSONDecoder()
                let serviceStores = try decoder.decode([GroceryStoreService].self, from: data)
                
                
                let stores = serviceStores.map { GroceryStore(from: $0) }
                
                for store in stores {
                    for component in store.component{
                        print("\(component.country_code)")
                    }
                    
                }
//
           }catch let jsonErr{
                print("Erreur oups....", jsonErr)
           }
//
//
       }.resume()
        
        urlGeo.text = "\(json2)"
        
        MyMap.setRegion(region, animated: true)
        self.MyMap.showsUserLocation = true
    }


}

