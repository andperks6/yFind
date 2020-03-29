import UIKit
import SceneKit
import ARKit
import ArcGIS
import ARCL
import CoreLocation

class ARViewController: UIViewController {
    var sceneLocationView = SceneLocationView()
//    @IBOutlet var sceneView: ARSCNView!
    
    var routePolyline:AGSPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        sceneView.delegate = self
//        sceneView.showsStatistics = true
//        sceneView.scene = SCNScene()
//        let circleNode = createSphereNode(with: 0.2, color: .gray)
//        circleNode.position = SCNVector3(0, 0, -1) // 1 meter in front of camera
//        sceneView.scene.rootNode.addChildNode(circleNode)

//        Loop through process, create annotation node for destination and each point on the AGSPolyline. Add each to the location view
        // altidue is in meters
        let coordinate = CLLocationCoordinate2D(latitude: 43.62543911527655, longitude: -116.3788297120482)
        let location = CLLocation(coordinate: coordinate, altitude: 793)
        let image = UIImage(named: "mapPin")!

        let annotationNode = LocationAnnotationNode(location: location, image: image)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
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
