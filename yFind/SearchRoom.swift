//
//  SearchRoom.swift
//  yFind
//
//  Created by Taylor Bakow on 1/17/20.
//  Copyright © 2020 Esri. All rights reserved.
//

import Foundation
import UIKit

class SearchRoom: UIViewController {
    
    var bldg:String? = ""
    
    @IBOutlet weak var roomInput: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "roomSegue"){
                let displayVC = segue.destination as! ConfirmationView
                displayVC.room = roomInput.text
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
