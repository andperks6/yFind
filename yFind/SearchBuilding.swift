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

class SearchBuilding: UIViewController {
    
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bldgInput: UISearchBar!
    
    var searchController: UISearchController!
    var originalDataSource: [String] = []
    var currentDataSource: [String] = []
    var selectedRow: String = ""
    
    private var featureTable: AGSServiceFeatureTable?
    private var selectedFeatures = [AGSFeature]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let indoorurl = URL(string: "https://services.arcgis.com/FvF9MZKp3JWPrSkg/arcgis/rest/services/BYU_Campus_Buildings/FeatureServer/0")!
        self.featureTable = AGSServiceFeatureTable(url: indoorurl)
        
        originalDataSource = selectFeaturesForSearchTerm("")
        
        currentDataSource = originalDataSource
        
        tableView.delegate = self
        tableView.dataSource = self

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.delegate = self

    }
    
    func addBuildingToDataSource(buildingCount: Int, Building: String) {
        for index in 1...buildingCount {
            originalDataSource.append("\(Building) #\(index)")
        }
    }
    
    func filterCurrentDataSource(searchTerm: String) {
        
        if searchTerm.count > 0 {
            
            currentDataSource = originalDataSource
            
            let filteredResults = currentDataSource.filter {$0.replacingOccurrences(of: " ", with: "").lowercased().contains(searchTerm.replacingOccurrences(of: " ", with: "").lowercased())
            }
            
            currentDataSource = filteredResults
            tableView.reloadData()
            
        }
    }
    
    func restoreCurrentDataSource() {
        currentDataSource = originalDataSource
        tableView.reloadData()
    }
    
    func selectFeaturesForSearchTerm(_ searchTerm: String) -> [String]{
        print("at least this prints")
        guard let featureTable = featureTable else {
                return []
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
                        self.originalDataSource.append(feature.attributes.value(forKey: "Name") as! String)
                    }
                    
                } else {

                }
                
                // update selected features array
                self.selectedFeatures = features
                
            }
            
        }
        
        return self.originalDataSource
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "bldgSegue"){
                let displayVC = segue.destination as! SearchRoom
            displayVC.bldg = self.selectedRow
        }
    }
    
    @IBAction func bldgButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "bldgSegue", sender: self)
    }
}

extension SearchBuilding: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text {
            filterCurrentDataSource(searchTerm: searchText)
        }
        
    }
}

extension SearchBuilding: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedRow = currentDataSource[indexPath.row]
        
        let alertController = UIAlertController(title: "Selection", message: "Selected \(currentDataSource[indexPath.row])", preferredStyle: .alert)
        
        searchController.isActive = false
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "bldgSegue", sender: nil)})
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = currentDataSource[indexPath.row]
        return cell
    }
    
}

extension SearchBuilding: UISearchBarDelegate {
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchController.isActive = false
            
            if let searchText = searchBar.text {
                filterCurrentDataSource(searchTerm: searchText)
            }
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchController.isActive = false
            
            if let searchText = searchBar.text, !searchText.isEmpty {
                restoreCurrentDataSource()
            }
        }
}
