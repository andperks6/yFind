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
    
    /// Overlay used to display user-placed graphics.
    private let graphicsOverlay: AGSGraphicsOverlay = {
        let overlay = AGSGraphicsOverlay()
        overlay.sceneProperties = AGSLayerSceneProperties(surfacePlacement: .absolute)
        return overlay
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.locationDataSource = AGSCLLocationDataSource()
       
        arView.translatesAutoresizingMaskIntoConstraints = false
        
        let shadowColor = UIColor.lightGray.withAlphaComponent(0.5)
        let shadow = AGSSimpleMarkerSceneSymbol(style: .sphere, color: shadowColor, height: 0.01, width: 0.25, depth: 0.25, anchorPosition: .center)
        let point = CGPoint(x: (arView.locationDataSource?.locationManager.location?.coordinate.latitude)!, y: (arView.locationDataSource?.locationManager.location?.coordinate.longitude)!)
        let shadowGraphic = AGSGraphic(geometry: arView.arScreenToLocation(screenPoint: point), symbol: shadow)
        graphicsOverlay.renderer = AGSSimpleRenderer(symbol: shadow)
        graphicsOverlay.graphics.add(shadowGraphic)
        
        
        arView.sceneView.graphicsOverlays.add(graphicsOverlay)

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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "switchToMap"){
            let displayVC = segue.destination as! ViewController
        }
    }
    
    

}

