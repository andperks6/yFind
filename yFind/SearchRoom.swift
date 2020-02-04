//
//  SearchRoom.swift
//  yFind
//
//  Created by Taylor Bakow on 1/17/20.
//  Copyright © 2020 Esri. All rights reserved.
//

import Foundation
import UIKit
import ArcGIS

class SearchRoom: UIViewController {
   
    //Incoming bldg variable
    var bldg:String? = ""
    
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomInput: UISearchBar!
    
    var searchController: UISearchController!
    var originalDataSource: [String] = []
    var currentDataSource: [String] = []
    var selectedRow: String = ""
    
    private var featureTable: AGSServiceFeatureTable?
    private var selectedFeatures = [AGSFeature]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let indoorurl = URL(string: "https://services.arcgis.com/FvF9MZKp3JWPrSkg/arcgis/rest/services/Floorplans_V/FeatureServer/0")!
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
    
    func filterCurrentDataSource(searchTerm: String) {
        
        if searchTerm.count > 0 {
            
            currentDataSource = originalDataSource
            
            let filteredResults = currentDataSource.filter {$0.replacingOccurrences(of: " ", with: "").lowercased().contains(searchTerm.replacingOccurrences(of: " ", with: "").lowercased())
            }
            
            currentDataSource = filteredResults
            tableView.reloadData()
            
        }
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
        queryParams.whereClause = "upper(RoomNumber) LIKE '%\(searchTerm.uppercased())%'"
        
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
                        self.originalDataSource.append(feature.attributes.value(forKey: "RoomNumber") as! String)
                    }
                    
                } else {

                }
                
                // update selected features array
                self.selectedFeatures = features
                
            }
            
        }
        
        return self.originalDataSource
        
    }
    
    func restoreCurrentDataSource() {
          currentDataSource = originalDataSource
          tableView.reloadData()
      }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "roomSegue"){
                let displayVC = segue.destination as! ConfirmationView
                displayVC.room = self.selectedRow
                displayVC.bldg = bldg
        }
    }
    
    @IBAction func roomButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "roomSegue", sender: self)
    }

    @IBAction func backToRoomSelect(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SearchRoom: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text {
            filterCurrentDataSource(searchTerm: searchText)
        }
        
    }
}

extension SearchRoom: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedRow = currentDataSource[indexPath.row]
        
        let alertController = UIAlertController(title: "Selection", message: "Selected \(currentDataSource[indexPath.row])", preferredStyle: .alert)
        
        searchController.isActive = false
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "roomSegue", sender: nil)})
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

extension SearchRoom: UISearchBarDelegate {
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
