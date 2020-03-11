import UIKit
import SceneKit
import ARKit
import ArcGIS

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var routePolyline:AGSPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.scene = SCNScene()
        let circleNode = createSphereNode(with: 0.2, color: .gray)
        circleNode.position = SCNVector3(0, 0, -1) // 1 meter in front of camera
        sceneView.scene.rootNode.addChildNode(circleNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        let tabBar = tabBarController as! TabBarController
        self.routePolyline = tabBar.routePolyline
        if let routePolyline = routePolyline{
            print("route Polyline: ",routePolyline)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func createSphereNode(with radius: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: geometry)
        return sphereNode
    }
}
