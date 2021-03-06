import UIKit
import SceneKit
import ARKit
import ArcGIS
import ARCL
import CoreLocation

class ARViewController: UIViewController {
    var sceneLocationView = SceneLocationView()
//    @IBOutlet var sceneView: ARSCNView!
    var end: AGSPoint?
    var routePolyline:AGSPolyline?

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBar = self.tabBarController as! TabBarController
        end = tabBar.end
        routePolyline = tabBar.routePolyline
        
        print(routePolyline?.parts[0].points)
        print(routePolyline?.parts[0].endPoint)
        print(routePolyline?.spatialReference)
        
        let markerLatitude = end?.y
        let markerLongitude = end?.x
        let markerAltitude = end?.z
        
        print(markerLatitude)
        print(markerLongitude)
        print(markerAltitude)
//        sceneView.delegate = self
//        sceneView.showsStatistics = true
//        sceneView.scene = SCNScene()
//        let circleNode = createSphereNode(with: 0.2, color: .gray)
//        circleNode.position = SCNVector3(0, 0, -1) // 1 meter in front of camera
//        sceneView.scene.rootNode.addChildNode(circleNode)

//        Loop through process, create annotation node for destination and each point on the AGSPolyline. Add each to the location view
        // altidue is in meters
        let coordinate = CLLocationCoordinate2D(latitude: routePolyline?.parts[0].endPoint?.y ?? 0, longitude: routePolyline?.parts[0].endPoint?.x ?? 0)
        let location = CLLocation(coordinate: coordinate, altitude: 793)
        let image = UIImage(named: "mapPin")!

        let annotationNode = LocationAnnotationNode(location: location, image: image)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        for p in 0..<((routePolyline?.parts[0].points.count)!-1) {
            let coordinate = CLLocationCoordinate2D(latitude: routePolyline?.parts[0].points[p].y ?? 0, longitude: routePolyline?.parts[0].points[p].x ?? 0)
            let location = CLLocation(coordinate: coordinate, altitude: 793)
            let image = UIImage(named: "blueDot")!

            let annotationNode = LocationAnnotationNode(location: location, image: image)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        }
//End loop
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      sceneLocationView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        let configuration = ARWorldTrackingConfiguration()
//        sceneView.session.run(configuration)
//        let tabBar = tabBarController as! TabBarController
//        self.routePolyline = tabBar.routePolyline
//        if let routePolyline = routePolyline{
//            print("route Polyline: ",routePolyline)
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        sceneView.session.pause()
    }
    
    func createSphereNode(with radius: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: geometry)
        return sphereNode
    }
}
