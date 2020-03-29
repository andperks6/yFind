//
//  TabBarController.swift
//  yFind
//
//  Created by Taylor Bakow on 3/9/20.
//  Copyright © 2020 Esri. All rights reserved.
//

import UIKit
import ArcGIS

class TabBarController: UITabBarController {

    @IBOutlet weak var TabBar: UITabBar!
    
    var routePolyline:AGSPolyline?
    var end: AGSPoint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let tabBarIcons = TabBar.items;
//        tabBarIcons?[0].badgeColor = .red;
//        tabBarIcons?[0].title = "Map View";
//        tabBarIcons?[1].badgeColor = .blue;
//        tabBarIcons?[1].title = "Guided View";
//        
    }
 
}
