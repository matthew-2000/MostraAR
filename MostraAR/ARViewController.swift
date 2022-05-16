//
//  ARViewController.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 16/05/22.
//

import UIKit
import ARKit
import RealityKit

class ARViewController: UIViewController {

    @IBOutlet weak var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureARView()
        createTV()
        
    }
    
    func configureARView() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical, .horizontal]
        config.detectionImages = referenceImages
        arView.session.delegate = self
        addCoaching()
        arView.enableTapOnObject()
        //arView.debugOptions = [.showAnchorGeometry]
        arView.session.run(config, options: [])
    }
    
    func createTV() {
        let dimensions: SIMD3<Float> = [70, 5, 50]
        
        // Create TV housing
        let housingMesh = MeshResource.generateBox(size: dimensions)
        let housingMaterial = SimpleMaterial(color: .black, roughness: 0.4, isMetallic: false)
        let housingEntity = ModelEntity(mesh: housingMesh, materials: [housingMaterial])
        
        // Create TV screen
        let screenMesh = MeshResource.generatePlane(width: dimensions.x, depth: dimensions.z)
        let screenMaterial = SimpleMaterial(color: .white, roughness: 0.2, isMetallic: false)
        let screenEntity = ModelEntity(mesh: screenMesh, materials: [screenMaterial])
        screenEntity.name = "tvScreen"
        
        // add screen to housing
        housingEntity.addChild(screenEntity)
        screenEntity.setPosition([0, dimensions.y/2 + 0.001, 0], relativeTo: housingEntity)
        
        // create anchor
        let anchor = AnchorEntity(.image(group: "AR Resources", name: "first"))
        anchor.addChild(housingEntity)
        arView.scene.addAnchor(anchor)
        
        housingEntity.generateCollisionShapes(recursive: true)
    }
    
}

extension ARView {
    
    func enableTapOnObject() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        if let entity = self.entity(at: tapLocation) as? ModelEntity, entity.name == "tvScreen" {
            loadVideoMaterial(for: entity)
        }
    }
    
    func loadVideoMaterial(for entity: ModelEntity) {
        let asset = AVAsset(url: Bundle.main.url(forResource: "DemoVideo", withExtension: "MOV")!)
        //let asset = AVAsset(url: URL(string: "https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.mp4")!)
        let playerItem = AVPlayerItem(asset: asset)
        
        let player = AVPlayer()
        entity.model?.materials = [VideoMaterial(avPlayer: player)]
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
}

// MARK: ARSessionDelegate
extension ARViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var status = ""
        switch camera.trackingState {
        case .notAvailable:
            status = "Not available..."
        case .limited(let reason):
            switch reason {
            case .initializing:
                status = "Initializing..."
            case .excessiveMotion:
                status = "Excessive motion..."
            case .insufficientFeatures:
                status = "Insufficient Feature..."
            case .relocalizing:
                status = "Relocalizing..."
            @unknown default:
                status = "Unknown..."
            }
        case .normal:
            status = "Ready."
        }
        print("Status: \(status)")
    }
    
}

// MARK: ARCoachingOverlayViewDelegate
extension ARViewController: ARCoachingOverlayViewDelegate {
    
    func addCoaching() {
        let coachingView = ARCoachingOverlayView()
        coachingView.frame = arView.bounds
        coachingView.delegate = self
        coachingView.goal = .anyPlane
        coachingView.session = arView.session
        arView.addSubview(coachingView)
    }
    
}