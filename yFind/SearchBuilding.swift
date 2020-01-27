//
//  SearchBuilding.swift
//  yFind
//
//  Created by Taylor Bakow on 1/17/20.
//  Copyright © 2020 Esri. All rights reserved.
//

import Foundation
import UIKit

class SearchBuilding: UIViewController {
    
    @IBOutlet weak var bldgInput: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "bldgSegue"){
                let displayVC = segue.destination as! SearchRoom
                displayVC.bldg = bldgInput.text
        }
    }
    
    @IBAction func bldgButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "bldgSegue", sender: self)
    }
}
