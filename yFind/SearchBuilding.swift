//
//  SearchBuilding.swift
//  yFind
//
//  Created by Taylor Bakow on 1/17/20.
//  Copyright © 2020 Esri. All rights reserved.
//

import Foundation
import UIKit
import ArcGIS


class SearchBuilding: UIViewController, UISearchBarDelegate {
    private var featureTable: AGSServiceFeatureTable?
    private var selectedFeatures = [AGSFeature]()
//    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let indoorurl = URL(string: "https://services.arcgis.com/FvF9MZKp3JWPrSkg/arcgis/rest/services/BYU_Campus_Buildings/FeatureServer/0")!
        
        self.featureTable = AGSServiceFeatureTable(url: indoorurl)
        selectFeaturesForSearchTerm("")
//        searchController.searchResultsUpdater = self
//        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.searchBar.sizeToFit()
//        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    
    func selectFeaturesForSearchTerm(_ searchTerm: String) {
        print("at least this prints")
        guard let featureTable = featureTable else {
                return
        }
        
        // deselect all selected features
        if !selectedFeatures.isEmpty {
            selectedFeatures.removeAll()
        }
        
        let queryParams = AGSQueryParameters()
        queryParams.whereClause = "upper(Name) LIKE '%\(searchTerm.uppercased())%' OR Upper(Acronym) LIKE '%\(searchTerm.uppercased())%'"
        
        featureTable.queryFeatures(with: queryParams) { [weak self] (result: AGSFeatureQueryResult?, error: Error?) in
            guard let self = self else {
                return
            }
            
            if let error = error {
                // display the error as an alert
                let alert = UIAlertController(title: "Error", message: String(error.localizedDescription), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else if let features = result?.featureEnumerator().allObjects {
                if !features.isEmpty {
                    // display the selection
                    for feature in features{
                        print(feature.attributes)
                    }
//                    print("featurelist: ", features)
                    
                } else {
                    //no matches
//                    if let fullExtent = featureLayer.fullExtent {
//                        // no matches, zoom to show everything in the layer
//                        self.mapView.setViewpointGeometry(fullExtent, padding: 50)
//                    }
                }
                
                // update selected features array
                self.selectedFeatures = features
            }
        }
    }
//    func updateSearchResults(for searchController: UISearchController) {
//
//    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search clicked!")
        if let text = searchBar.text {
            selectFeaturesForSearchTerm(text)
        }
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
