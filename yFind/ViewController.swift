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

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: AGSMapView!
    
    
    //    let url = URLComponents(
    //        string: "https://www.arcgis.com/home/item.html",
    //        queryItems = [URLQueryItem(name: "id", value: "7092e11ebd75439fa84cbab1e4c1f9ec")])
    //    let portalItem = AGSPortalItem(portal: portal, itemID: "c6f90b19164c4283884361005faea852")
    
    //    let vectorTileLayer = AGSArcGISVectorTiledLayer(url: URL(string:  "http://www.arcgis.com/home/item.html?id=850db44b9eb845d3bd42b19e8aa7a024"))
    
    private func setupMap() {
        let baseBackdrop = URL(string: "https://arcgisruntime.maps.arcgis.com/home/item.html?id=850db44b9eb845d3bd42b19e8aa7a024")!
        let byuBase = URL(string: "https://arcgisruntime.maps.arcgis.com/home/item.html?id=b25c40061a764eca87da3ab9de9256b6")!
        let byuBuildingTable = AGSServiceFeatureTable(url: URL(string: "https://services.arcgis.com/FvF9MZKp3JWPrSkg/arcgis/rest/services/Campus_Buildings/FeatureServer/0")!)
        let byuBuildingLayer = AGSFeatureLayer(featureTable: byuBuildingTable)
        
        let baseBackdropLayer = AGSArcGISVectorTiledLayer(url: baseBackdrop)
        let byuBaseLayer = AGSArcGISVectorTiledLayer(url: byuBase)

        mapView.map = AGSMap(
            //            basemap: AGSBasemap(baseLayer: vectorTiledLayer),
            basemapType: .navigationVector,
            latitude: 40.249251,
            longitude: -111.649278,
            levelOfDetail: 15
        )
        
        mapView.map!.operationalLayers.add(byuBuildingLayer)
        
        
        
        
        //mapView.map?.basemap = AGSBasemap(baseLayers: [baseBackdropLayer, BYUBaseLayer], referenceLayers: [])
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }
}
