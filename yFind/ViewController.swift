// Copyright 2017 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ArcGIS
import CoreLocation

class ViewController: UIViewController, AGSCalloutDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet var routeBBI: UIBarButtonItem!
    @IBOutlet var directionsListBBI: UIBarButtonItem!
    
    @IBOutlet weak var switchToGuided: UIButton!
    
    var locationManager = CLLocationManager()
    
    //variables passed in
    var room:String? = ""
    var bldg:String? = ""
    var acronym:String? = ""
    var roomFeature: AGSFeature!
    
    let graphicsOverlay = AGSGraphicsOverlay()
    var start: AGSPoint?
    var end: AGSPoint?
    var routeTask = AGSRouteTask(url: URL(string: "https://utility.arcgis.com/usrsvcs/servers/a8ee36150d1b4178b33affcb5d7027cb/rest/services/World/Route/NAServer/Route_World")!)
    var routeParameters: AGSRouteParameters!
    var stopGraphicsOverlay = AGSGraphicsOverlay()
    var routeGraphicsOverlay = AGSGraphicsOverlay()
    var generatedRoute: AGSRoute! {
        didSet {
            let flag = generatedRoute != nil
            self.directionsListBBI.isEnabled = flag
        }
    }
    
    //    let url = URLComponents(
    //        string: "https://www.arcgis.com/home/item.html",
    //        queryItems = [URLQueryItem(name: "id", value: "7092e11ebd75439fa84cbab1e4c1f9ec")])
    //    let portalItem = AGSPortalItem(portal: portal, itemID: "c6f90b19164c4283884361005faea852")
    
    //    let vectorTileLayer = AGSArcGISVectorTiledLayer(url: URL(string:  "http://www.arcgis.com/home/item.html?id=850db44b9eb845d3bd42b19e8aa7a024"))

    private func setupMap() {
        let baseBackdrop = URL(string: "https://arcgisruntime.maps.arcgis.com/home/item.html?id=850db44b9eb845d3bd42b19e8aa7a024")!
        let byuBase = URL(string: "https://arcgisruntime.maps.arcgis.com/home/item.html?id=b25c40061a764eca87da3ab9de9256b6")!
        let byuBuildingTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/FvF9MZKp3JWPrSkg/arcgis/rest/services/Campus_Buildings/FeatureServer/0")!)
        let byuIndoorTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/FvF9MZKp3JWPrSkg/arcgis/rest/services/Floorplans_V/FeatureServer/0")!)
        
        
        let byuIndoorLayer = AGSFeatureLayer(featureTable: byuIndoorTable)
        let byuBuildingLayer = AGSFeatureLayer(featureTable: byuBuildingTable)
        let baseBackdropLayer = AGSArcGISVectorTiledLayer(url: baseBackdrop)
        let byuBaseLayer = AGSArcGISVectorTiledLayer(url: byuBase)

        mapView.map = AGSMap(
            
            basemapType: .navigationVector,
            latitude: 40.249251,
            longitude: -111.649278,
            levelOfDetail: 15
        )
//        mapView.map?.basemap = AGSBasemap(baseLayer: byuBaseLayer)
        mapView.map!.operationalLayers.add(byuBuildingLayer)
        mapView.map!.operationalLayers.add(byuIndoorLayer)
        mapView.graphicsOverlays.addObjects(from: [routeGraphicsOverlay, stopGraphicsOverlay])
        //mapView.map?.basemap = AGSBasemap(baseLayers: [baseBackdropLayer, BYUBaseLayer], referenceLayers: [])
    }
    
    private func showAlert(withStatus: String) {
          let alertController = UIAlertController(title: "Alert", message:
              withStatus, preferredStyle: UIAlertController.Style.alert)
          alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
          present(alertController, animated: true, completion: nil)
      }
      
    func setupLocationDisplay() {
          mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanMode.compassNavigation
          mapView.locationDisplay.start { [weak self] (error:Error?) -> Void in
              if let error = error {
                  self?.showAlert(withStatus: error.localizedDescription)
              }
          }
        
      }

    override func viewDidLoad() {
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
        CLLocationManager.authorizationStatus() == .authorizedAlways) {
           currentLoc = locationManager.location
           print(currentLoc.coordinate.latitude)
           print(currentLoc.coordinate.longitude)
        }
        super.viewDidLoad()

        setupMap()
        setupLocationDisplay()
        self.start = AGSPoint(x: currentLoc.coordinate.longitude, y: currentLoc.coordinate.latitude, spatialReference: AGSSpatialReference.wgs84())

        print("roomFeature point", self.roomFeature!.geometry!.extent.center)
        print("roomFeature x", self.roomFeature!.geometry!.extent.center.x)
        print("roomFeature x", self.roomFeature!.geometry!.extent.center.y)
        print("roomFeature copy", self.roomFeature!.geometry!.extent.center.copy())
        print("roomFeature self", self.roomFeature!.geometry!.extent.center.self)
        print("roomFeature spatial reference", self.roomFeature!.geometry!.extent.center.spatialReference)

        print("start point", self.start)
        self.end = (self.roomFeature!.geometry!.extent.center) as AGSPoint
        setStartMarker(location: self.start!)
        print("end", self.end, "start", self.start)
        setEndMarker(location: self.roomFeature!.geometry!.extent.center)
    }
    private func findRoute() {
        routeTask.defaultRouteParameters { [weak self] (defaultParameters, error) in
            guard error == nil else {
                print("Error getting default parameters: \(error!.localizedDescription)")
                return
            }
            
            guard let params = defaultParameters, let self = self, let start = self.start, let end = self.end else { return }
            
            params.setStops([AGSStop(point: start), AGSStop(point: end)])
            
            self.routeTask.solveRoute(with: params, completion: { (result, error) in
                guard error == nil else {
                    print("Error solving route: \(error!.localizedDescription)")
                    return
                }
                
                if let firstRoute = result?.routes.first, let routePolyline = firstRoute.routeGeometry {
                    let routeSymbol = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 4)
                    let routeGraphic = AGSGraphic(geometry: routePolyline, symbol: routeSymbol, attributes: nil)
//                    self.graphicsOverlay.graphics.add(routeGraphic)
                    self.routeGraphicsOverlay.graphics.add(routeGraphic)

                    let totalDistance = Measurement(value: firstRoute.totalLength, unit: UnitLength.meters)
                    let totalDuration = Measurement(value: firstRoute.travelTime, unit: UnitDuration.minutes)
                    
                    let formatter = MeasurementFormatter()
                    formatter.numberFormatter.maximumFractionDigits = 2
                    formatter.unitOptions = .naturalScale
                    
                    let alert = UIAlertController(title: nil, message: """
                        Total distance: \(formatter.string(from: totalDistance))
                        Travel time: \(formatter.string(from: totalDuration))
                        """, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        if start == nil {
            // Start is not set, set it to a tapped location.
            setStartMarker(location: mapPoint)
        } else if end == nil {
            // End is not set, set it to the tapped location then find the route.
            setEndMarker(location: mapPoint)
        } else {
            // Both locations are set; re-set the start to the tapped location.
            setStartMarker(location: mapPoint)
        }
    }
    
//    private func setupRouting(){
//        self.routeTask = AGSRouteTask(url: URL(string: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/NetworkAnalysis/SanDiego/NAServer/Route")!)
//
//        self.routeTask.load { [weak self] (error) -> Void in
//            if let error = error {
//                print(error)
//                return
//            }
//            if (self?.routeTask.loadStatus == .loaded) {
//                print("route task is loaded")
//            }
//        }
//        self?.routeTask.defaultRouteParameters(completion: { [weak self] (params, error) -> Void in
//        if let error = error {
//            print(error)
//            return
//        }
//        print("route task parameters")
//        //store the route parameters
//        self?.routeParameters = params
//        self?.routeParameters.returnDirections = true
//        self?.routeParameters.returnRoutes = true
//        self?.routeParameters.outputSpatialReference = self?.mapView.spatialReference
//         })
//    }
    private func addMapMarker(location: AGSPoint, style: AGSSimpleMarkerSymbolStyle, fillColor: UIColor, outlineColor: UIColor) {
        let pointSymbol = AGSSimpleMarkerSymbol(style: style, color: fillColor, size: 8)
        pointSymbol.outline = AGSSimpleLineSymbol(style: .solid, color: outlineColor, width: 2)
        let markerGraphic = AGSGraphic(geometry: location, symbol: pointSymbol, attributes: nil)
//        graphicsOverlay.graphics.add(markerGraphic)
        stopGraphicsOverlay.graphics.add(markerGraphic)
    }

    private func setStartMarker(location: AGSPoint) {
        graphicsOverlay.graphics.removeAllObjects()
        let startMarkerColor = UIColor(red:0.886, green:0.467, blue:0.157, alpha:1.000)
        addMapMarker(location: location, style: .diamond, fillColor: startMarkerColor, outlineColor: .blue)
        start = location
        end = nil
    }

    private func setEndMarker(location: AGSPoint) {
        let endMarkerColor = UIColor(red:0.157, green:0.467, blue:0.886, alpha:1.000)
        addMapMarker(location: location, style: .square, fillColor: endMarkerColor, outlineColor: .red)
        end = location
        findRoute()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "switchToGuided"){
            let displayVC = segue.destination as! ARViewController
        }
    }
}
