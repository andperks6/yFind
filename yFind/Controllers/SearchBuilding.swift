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
import CoreLocation

class SearchBuilding: UIViewController {
    
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bldgInput: UISearchBar!
    
    var searchController: UISearchController!
    var originalDataSource: [String] = []
    var currentDataSource: [(String, String)] = []
    var selectedRow: (String, String) = ("","")
    var locationManager = CLLocationManager()
    
    private var featureTable: AGSServiceFeatureTable?
    private var selectedFeatures = [AGSFeature]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        
        let indoorurl = URL(string: "https://services.arcgis.com/FvF9MZKp3JWPrSkg/arcgis/rest/services/BYU_Campus_Buildings/FeatureServer/0")!
        self.featureTable = AGSServiceFeatureTable(url: indoorurl)
        
//        currentDataSource
        selectFeaturesForSearchTerm("")
        
        tableView.delegate = self
        tableView.dataSource = self
    
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        let searchBar = searchController.searchBar
        searchBar.clipsToBounds = true;
        searchBar.sizeToFit()
        searchBar.searchBarStyle = .minimal
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .black;
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = .black
        searchContainerView.clipsToBounds = true;
        searchContainerView.addSubview(searchBar)
        searchController.searchBar.delegate = self
    }
    
    func addBuildingToDataSource(buildingCount: Int, Building: String) {
        for index in 1...buildingCount {
            originalDataSource.append("\(Building) #\(index)")
        }
    }
    
    func selectFeaturesForSearchTerm(_ searchTerm: String) {
        guard let featureTable = featureTable else {
                return
        }
        print("searching: ", searchTerm)
        // deselect all selected features
        if !selectedFeatures.isEmpty {
            selectedFeatures.removeAll()
        }
        
        let queryParams = AGSQueryParameters()
        queryParams.whereClause = "(upper(Name) LIKE '%\(searchTerm.uppercased())%' OR Upper(Acronym) LIKE '%\(searchTerm.uppercased())%')"
        queryParams.orderByFields = [AGSOrderBy(fieldName: "Acronym", sortOrder: .ascending)]
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
                    self.currentDataSource = []
                    // display the selection
                    for feature in features{
                        let acronym = feature.attributes.value(forKey: "Acronym")
                        let name = feature.attributes.value(forKey: "Name" )
                        self.currentDataSource.append((acronym as! String, name as! String))
                    }
                    self.tableView.reloadData()
                } else {

                }
                // update selected features array
                self.selectedFeatures = features
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "bldgSegue"){
                let displayVC = segue.destination as! SearchRoom
            displayVC.bldg = self.selectedRow.1
            displayVC.acronym = self.selectedRow.0
            searchController.isActive = false;
        }
    }
    
    @IBAction func bldgButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "bldgSegue", sender: self)
    }
}

extension SearchBuilding: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text {
            selectFeaturesForSearchTerm(searchText)
        }
        
    }
}

extension SearchBuilding: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedRow = currentDataSource[indexPath.row]
        
        self.performSegue(withIdentifier: "bldgSegue", sender: nil)
        
//        let alertController = UIAlertController(title: "Selection", message: "Selected \(currentDataSource[indexPath.row])", preferredStyle: .alert)
//
//        searchController.isActive = false
//        
//        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in
//            self.performSegue(withIdentifier: "bldgSegue", sender: nil)})
//        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = currentDataSource[indexPath.row].0
        cell.detailTextLabel?.text = currentDataSource[indexPath.row].1
        return cell
    }
    
}

extension SearchBuilding: UISearchBarDelegate {
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchController.isActive = false
            
            if let searchText = searchBar.text {
                selectFeaturesForSearchTerm(searchText)
            }
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchController.isActive = false
            
            if let searchText = searchBar.text, !searchText.isEmpty {
                selectFeaturesForSearchTerm("")
            }
        }
}
