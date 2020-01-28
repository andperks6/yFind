//
//  testSearch.swift
//  yFind
//
//  Created by Andrew Perkins on 1/21/20.
//  Copyright © 2020 Esri. All rights reserved.
//

//import SwiftUI
//
//struct testSearch: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//struct testSearch_Previews: PreviewProvider {
//    static var previews: some View {
//        testSearch()
//    }
//}
import UIKit
import ArcGIS

class testSearch: UIViewController, UISearchBarDelegate {
    @IBOutlet private weak var mapView: AGSMapView!
    
    private var featureTable: AGSServiceFeatureTable?
    private var featureLayer: AGSFeatureLayer?
    
    private var selectedFeatures = [AGSFeature]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add the source code button item to the right of navigation bar
        
//        (navigationItem.rightBarButtonItem as! SourceCodeBarButtonItem).filenames = ["FLQueryViewController"]
        
        // initialize map with topographic basemap
        let map = AGSMap(basemap: .topographic())
        // assign map to the map view
        mapView.map = map
        
        /// The url of a map service layer containing sample census data of United States counties.
        let statesFeatureTableURL = URL(string: "https://services.arcgis.com/jIL9msH9OI208GCb/arcgis/rest/services/USA_Daytime_Population_2016/FeatureServer/0")!
        // create feature table using a url
        let featureTable = AGSServiceFeatureTable(url: statesFeatureTableURL)
        self.featureTable = featureTable
        
        // create feature layer using this feature table
        let featureLayer = AGSFeatureLayer(featureTable: featureTable)
        self.featureLayer = featureLayer
        // show the layer at all scales
        featureLayer.minScale = 0
        featureLayer.maxScale = 0
        
        // set a new renderer
        let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: .black, width: 1)
        let fillSymbol = AGSSimpleFillSymbol(style: .solid, color: UIColor.yellow.withAlphaComponent(0.5), outline: lineSymbol)
        featureLayer.renderer = AGSSimpleRenderer(symbol: fillSymbol)
        
        // add feature layer to the map
        map.operationalLayers.add(featureLayer)
        
        // center the layer
        mapView.setViewpointCenter(AGSPoint(x: -11e6, y: 5e6, spatialReference: .webMercator()), scale: 9e7)
    }
    
    func selectFeaturesForSearchTerm(_ searchTerm: String) {
        guard let featureLayer = featureLayer,
            let featureTable = featureTable else {
                return
        }
        
        // deselect all selected features
        if !selectedFeatures.isEmpty {
            featureLayer.unselectFeatures(selectedFeatures)
            selectedFeatures.removeAll()
        }
        
        let queryParams = AGSQueryParameters()
        queryParams.whereClause = "upper(STATE_NAME) LIKE '%\(searchTerm.uppercased())%'"
        
        featureTable.queryFeatures(with: queryParams) { [weak self] (result: AGSFeatureQueryResult?, error: Error?) in
            guard let self = self else {
                return
            }
            
            if let error = error {
                // display the error as an alert
//                self.presentAlert(error: error)
                let alert = UIAlertController(title: "Error", message: String(error.localizedDescription), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else if let features = result?.featureEnumerator().allObjects {
                if !features.isEmpty {
                    // display the selection
                    featureLayer.select(features)
                    
                    // zoom to the selected feature
                    self.mapView.setViewpointGeometry(features.first!.geometry!, padding: 25)
                } else {
                    if let fullExtent = featureLayer.fullExtent {
                        // no matches, zoom to show everything in the layer
                        self.mapView.setViewpointGeometry(fullExtent, padding: 50)
                    }
                }
                
                // update selected features array
                self.selectedFeatures = features
            }
        }
    }
    
    // MARK: - Search bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            selectFeaturesForSearchTerm(text)
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
