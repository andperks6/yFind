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

struct RoomVariables {
    
    static var selectedFeature: AGSFeature!
    
}


class SearchRoom: UIViewController {
   
    //Incoming bldg variable
    var bldg:String? = ""
    var acronym:String? = ""
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomInput: UISearchBar!
    @IBOutlet weak var myLabel: UILabel!
    
    var searchController: UISearchController!
    var currentDataSource: [String] = []
    var selectedRow: String = ""
    
    private var featureTable: AGSServiceFeatureTable?
    private var selectedFeatures = [AGSFeature]()
    private var selectedFeature: AGSFeature!
    override func viewDidLoad() {
        super.viewDidLoad()
        let indoorurl = URL(string: "https://services.arcgis.com/FvF9MZKp3JWPrSkg/arcgis/rest/services/Floorplans_V/FeatureServer/0")!
        self.featureTable = AGSServiceFeatureTable(url: indoorurl)
        print(acronym!)
        
//        self.featureTable?.definitionExpression = "BLDG_SHORT='\(acronym!)'"
        selectFeaturesForSearchTerm("")
        
//        currentDataSource = originalDataSource
        
        tableView.delegate = self
        tableView.dataSource = self

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        let searchBar = searchController.searchBar
        searchBar.clipsToBounds = true;
        searchBar.sizeToFit()
        searchBar.searchBarStyle = .minimal
        searchContainerView.clipsToBounds = true;
        searchContainerView.addSubview(searchBar)
        searchController.searchBar.delegate = self
        self.myLabel?.text = "Enter a Room Number for \(bldg ?? "This Building")"
    }
    
//    func filterCurrentDataSource(searchTerm: String) {
//
//        if searchTerm.count > 0 {
//
//            currentDataSource = originalDataSource
//
//            let filteredResults = currentDataSource.filter {$0.replacingOccurrences(of: " ", with: "").lowercased().contains(searchTerm.replacingOccurrences(of: " ", with: "").lowercased())
//            }
//
//            currentDataSource = filteredResults
//            tableView.reloadData()
//
//        }
//    }
    
    func selectFeaturesForSearchTerm(_ searchTerm: String) {
        guard let featureTable = featureTable else {
                return
        }
        
        // deselect all selected features
        if !selectedFeatures.isEmpty {
            selectedFeatures.removeAll()
        }
        
        let queryParams = AGSQueryParameters()
        queryParams.whereClause = "upper(RoomNumber) LIKE '%\(searchTerm.uppercased())%' AND BLDG_SHORT='\(acronym!)'"
        queryParams.orderByFields = [AGSOrderBy(fieldName: "RoomNumber", sortOrder: .ascending)]

        featureTable.queryFeatures(with: queryParams, queryFeatureFields: .loadAll) { [weak self] (result: AGSFeatureQueryResult?, error: Error?) in
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
//                        print(feature.geometry)
                        self.currentDataSource.append(feature.attributes.value(forKey: "RoomNumber") as! String)
                        self.tableView.reloadData()
                    }
                    
                } else {

                }
                
                // update selected features array
                self.selectedFeatures = features
            }
            
        }
    }
    
//    func restoreCurrentDataSource() {
//          currentDataSource = originalDataSource
//          tableView.reloadData()
//      }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "roomSegue"){
            let displayVC = segue.destination as! ConfirmationView
            displayVC.room = self.selectedRow
            displayVC.bldg = bldg
            displayVC.roomFeature = RoomVariables.selectedFeature
            displayVC.acronym = acronym
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
//            filterCurrentDataSource(searchTerm: searchText)
            selectFeaturesForSearchTerm(searchText)
        }
        
    }
}

extension SearchRoom: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedRow = currentDataSource[indexPath.row]
        RoomVariables.selectedFeature = selectedFeatures[indexPath.row]
//        print(self.selectedFeature.geometry?.geometryType)
//        print("extent: ", self.selectedFeature.geometry?.extent)
//        print("center: ", self.selectedFeature.geometry?.extent.center)

//        let alertController = UIAlertController(title: "Selection", message: "Selected \(currentDataSource[indexPath.row])", preferredStyle: .alert)
//
//        searchController.isActive = false
//        
//        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in
//            self.performSegue(withIdentifier: "roomSegue", sender: nil)})
//        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)
//
        self.performSegue(withIdentifier: "roomSegue", sender: nil)
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
                selectFeaturesForSearchTerm(searchText)
//                filterCurrentDataSource(searchTerm: searchText)
            }
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchController.isActive = false
            
            if let searchText = searchBar.text, !searchText.isEmpty {
//                restoreCurrentDataSource()
                selectFeaturesForSearchTerm("")
            }
        }
}
