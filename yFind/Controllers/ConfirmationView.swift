//
//  Confirmation.swift
//  yFind
//
//  Created by Taylor Bakow on 1/22/20.
//  Copyright © 2020 Esri. All rights reserved.
//

import Foundation
import UIKit
import ArcGIS
class ConfirmationView: UIViewController {
    
    var room:String? = ""
    var bldg:String? = ""
    var acronym:String? = ""
    var roomFeature: AGSFeature?
    
    @IBOutlet weak var confLabel: UILabel!

    override func viewDidLoad() {
          super.viewDidLoad()
          confLabel.text = "Go to " + acronym! + " " + room!;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "confirmationSegue"){
            let displayVC = segue.destination as! ViewController
            displayVC.room = room
            displayVC.bldg = bldg
            displayVC.roomFeature = roomFeature
            displayVC.acronym = acronym
        }
    }
    
//    @IBAction func roomButtonAction(_ sender: Any) {
//        self.performSegue(withIdentifier: "roomSegue", sender: self)
//    }
}
