//
//  ARViewController.swift
//  yFind
//
//  Created by Taylor Bakow on 2/25/20.
//  Copyright © 2020 Esri. All rights reserved.
//

import UIKit
import ARKit
import ArcGISToolkit
import ArcGIS

class ARViewController: UIViewController {

    @IBOutlet weak var switchToMap: UIButton!
    
    @IBOutlet weak var cameraView: UIView!
    
    private let arView = ArcGISARView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.locationDataSource = AGSCLLocationDataSource()
       
        arView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(arView)

        NSLayoutConstraint.activate([
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
            switchToMap.superview?.bringSubviewToFront(switchToMap)
    }
    
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Continuous update mode
        arView.startTracking(.continuous, completion: nil)

        // One-time update mode
        // arView.startTracking(.initial, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        arView.stopTracking()
    }

    private func configureSceneForAR() {
        // Create scene with imagery basemap
        let scene = AGSScene(basemapType: .imagery)

        // Create an elevation source and add it to the scene
        let elevationSource = AGSArcGISTiledElevationSource(url:
            URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!)
        scene.baseSurface?.elevationSources.append(elevationSource)

        // Allow camera to go beneath the surface
        scene.baseSurface?.navigationConstraint = .none

        // Display the scene
        arView.sceneView.scene = scene

        // Configure atmosphere and space effect
        arView.sceneView.atmosphereEffect = .none
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


//     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "switchToMap"){
            let displayVC = segue.destination as! ViewController
        }
    }

}
