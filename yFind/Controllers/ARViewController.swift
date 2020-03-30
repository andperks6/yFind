import UIKit
import SceneKit
import ARKit
import ArcGIS
import ARCL
import MapKit
import CoreLocation

class ARViewController: UIViewController {
    var sceneLocationView = SceneLocationView()
//    @IBOutlet var sceneView: ARSCNView!
    var end: AGSPoint?
    var routePolyline:AGSPolyline?
    var mapkitPolyline:MKPolyline?
    var locations: Array<CLLocationCoordinate2D> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBar = self.tabBarController as! TabBarController
        end = tabBar.end
        routePolyline = tabBar.routePolyline
        
        let coordinate = CLLocationCoordinate2D(latitude: routePolyline?.parts[0].endPoint?.y ?? 0, longitude: routePolyline?.parts[0].endPoint?.x ?? 0)
        let location = CLLocation(coordinate: coordinate, altitude: 793)
        let image = UIImage(named: "mapPin")!

        let annotationNode = LocationAnnotationNode(location: location, image: image)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        for p in 0..<((routePolyline?.parts[0].points.count)!-1) {
            let coordinate = CLLocationCoordinate2D(latitude: routePolyline?.parts[0].points[p].y ?? 0, longitude: routePolyline?.parts[0].points[p].x ?? 0)
            let location = CLLocation(coordinate: coordinate, altitude: 793)
            locations.append(location.coordinate)
//            let image = UIImage(named: "blueDot")!
//            let annotationNode = LocationAnnotationNode(location: location, image: image)
//            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
            
            
            //get previous location to draw line from point to point
            
//           if(p - 1 > 0){
//               let coordinate2 = CLLocationCoordinate2D(latitude: routePolyline?.parts[0].points[p - 1].y ?? 0, longitude: routePolyline?.parts[0].points[p - 1].x ?? 0)
//               let location2 = CLLocation(coordinate: coordinate2, altitude: 793)
//               let annotationNode2 = LocationAnnotationNode(location: location2, image: image)
//               let toPoint = annotationNode.eulerAngles
//               let fromPoint = annotationNode2.eulerAngles
//               let line = lineFrom(vector: fromPoint, toVector: toPoint)
//               let lineNode = SCNNode(geometry: line)
//               lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
//               sceneLocationView.sceneNode?.addChildNode(lineNode)
//           }
        }
        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        
        var mkpolys: Array<MKPolyline> = []
        mkpolys.append(polyline)
        sceneLocationView.addPolylines(polylines: mkpolys)
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
    
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
        
    }
}
