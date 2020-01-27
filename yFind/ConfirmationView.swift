//
//  Confirmation.swift
//  yFind
//
//  Created by Taylor Bakow on 1/22/20.
//  Copyright © 2020 Esri. All rights reserved.
//

import Foundation
import UIKit

class ConfirmationView: UIViewController {
    
    var room:String? = ""
    var bldg:String? = ""
    
    @IBOutlet weak var confLabel: UILabel!

    override func viewDidLoad() {
          super.viewDidLoad()
          confLabel.text = "Go to " + bldg! + " " + room!;
    }
}
