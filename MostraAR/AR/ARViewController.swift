//
//  ARViewController.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 16/05/22.
//

import UIKit
import ARKit
import RealityKit
import Vision

class ARViewController: UIViewController {

    @IBOutlet weak var arView: ARView!
    var recentIndexFingerPoint : CGPoint = .zero
    var viewWidth : Int = 0
    var viewHeight : Int = 0
    var numAlbumImage = 1
    var isRunning = false
    var timer = Timer()

    lazy var request : VNRequest = {
        var handPoseRequest = VNDetectHumanHandPoseRequest(completionHandler: handDetectionCompletionHandler)
        handPoseRequest.maximumHandCount = 1
        return handPoseRequest
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.isRunning = false
        })
        configureARView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        arView.scene.anchors.removeAll()
        arView.session.pause()
        arView.session.delegate = nil
        arView.removeFromSuperview()
    }
    
    func configureARView() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical, .horizontal]
        config.environmentTexturing = .automatic
        config.frameSemantics = [.personSegmentation]
        config.detectionImages = referenceImages
        viewWidth = Int(arView.bounds.width)
        viewHeight = Int(arView.bounds.height)
        arView.session.delegate = self
        addCoaching()
        //arView.enableTapOnObject()
        //arView.debugOptions = [.showAnchorGeometry]
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors, .resetSceneReconstruction])
        //addFocusSquare()
    }
    
    @IBAction func addOnClick(_ sender: Any) {
        createTV()
    }
    
    func createTV() {
        //let dimensions: SIMD3<Float> = [70, 5, 50]
        let dimensions: SIMD3<Float> = [1, 0.05, 0.7]
        
        // Create TV housing
        let housingMesh = MeshResource.generateBox(size: [dimensions.x + 0.05, dimensions.y, dimensions.z + 0.05], cornerRadius: 10)
        let housingMaterial = SimpleMaterial(color: .black, roughness: 0.4, isMetallic: true)
        let housingEntity = ModelEntity(mesh: housingMesh, materials: [housingMaterial])
        
        // Create TV screen
        let screenMesh = MeshResource.generatePlane(width: dimensions.x, depth: dimensions.z)
        let screenMaterial = SimpleMaterial(color: .white, roughness: 0.2, isMetallic: false)
        let screenEntity = ModelEntity(mesh: screenMesh, materials: [screenMaterial])
        screenEntity.name = "tvScreen"
        let asset = AVAsset(url: Bundle.main.url(forResource: "DemoVideo", withExtension: "MOV")!)
        //let asset = AVAsset(url: URL(string: "https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.mp4")!)
        let playerItem = AVPlayerItem(asset: asset)
        screenEntity.model?.materials = [VideoMaterial(avPlayer: player)]
        player.replaceCurrentItem(with: playerItem)
        
        // Create start button
        let buttonEntity = ARObjectCreator.createPlayButton()
        //add button to housing
        screenEntity.addChild(buttonEntity)
        buttonEntity.setPosition([-0.30, dimensions.y + 0.025, dimensions.z/2 + 0.05], relativeTo: screenEntity)
        screenEntity.generateCollisionShapes(recursive: true)
        
        // Create pause button
        let pauseEntity = ARObjectCreator.createPauseButton()
        //add button to housing
        screenEntity.addChild(pauseEntity)
        pauseEntity.setPosition([0.30, dimensions.y + 0.025, dimensions.z/2 + 0.05], relativeTo: screenEntity)
        screenEntity.generateCollisionShapes(recursive: true)
        
        // Create restart button
        let restartButton = ARObjectCreator.createRestartButton()
        //add button to housing
        screenEntity.addChild(restartButton)
        restartButton.setPosition([0, dimensions.y + 0.025, dimensions.z/2 + 0.20], relativeTo: screenEntity)
        screenEntity.generateCollisionShapes(recursive: true)
        
        // add screen to housing
        housingEntity.addChild(screenEntity)
        screenEntity.setPosition([0, dimensions.y/2 + 0.001, 0], relativeTo: housingEntity)
        
        // create anchor
        housingEntity.generateCollisionShapes(recursive: true)
        let anchor = AnchorEntity(plane: .vertical)
        anchor.addChild(housingEntity)
        arView.scene.addAnchor(anchor)
        
        hapticFeedback()
    }
    
    @IBAction func closeOnClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: Video Controller
    var isPlaying = false
    var isPaused = false
    let player = AVPlayer()
    
    func pauseVideo() {
        player.pause()
        hapticFeedback()
    }
    
    func playVideo() {
        player.play()
        hapticFeedback()
    }
    
    func restartVideo(for entity: ModelEntity) {
        let asset = AVAsset(url: Bundle.main.url(forResource: "DemoVideo", withExtension: "MOV")!)
        //let asset = AVAsset(url: URL(string: "https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.mp4")!)
        let playerItem = AVPlayerItem(asset: asset)
        entity.model?.materials = [VideoMaterial(avPlayer: player)]
        player.replaceCurrentItem(with: playerItem)
        player.play()
        hapticFeedback()
    }
    
    
    // MARK: Haptic Feedback
    func hapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
}
