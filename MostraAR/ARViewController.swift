//
//  ARViewController.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 16/05/22.
//

import UIKit
import ARKit
import RealityKit
import FocusEntity
import Vision

class ARViewController: UIViewController {

    @IBOutlet weak var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        config.planeDetection = [.vertical]
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
        addFocusSquare()
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
        let buttonEntity = createPlayButton()
        //add button to housing
        screenEntity.addChild(buttonEntity)
        buttonEntity.setPosition([-0.30, dimensions.y + 0.025, dimensions.z/2 + 0.05], relativeTo: screenEntity)
        screenEntity.generateCollisionShapes(recursive: true)
        
        // Create pause button
        let pauseEntity = createPauseButton()
        //add button to housing
        screenEntity.addChild(pauseEntity)
        pauseEntity.setPosition([0.30, dimensions.y + 0.025, dimensions.z/2 + 0.05], relativeTo: screenEntity)
        screenEntity.generateCollisionShapes(recursive: true)
        
        // Create restart button
        let restartButton = createRestartButton()
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
    
    func createPlayButton() -> ModelEntity {
        let buttonMesh = MeshResource.generateBox(size: SIMD3<Float>(0.30, 0.05, 0.10), cornerRadius: 10)
        let buttonMaterial = SimpleMaterial(color: .systemBlue, roughness: 0.4, isMetallic: false)
        let buttonEntity = ModelEntity(mesh: buttonMesh, materials: [buttonMaterial])
        buttonEntity.name = "playButton"
        let text = MeshResource.generateText("Play",
                              extrusionDepth: 0,
                                        font: .systemFont(ofSize: 0.07),
                              containerFrame: .zero,
                                   alignment: .center,
                               lineBreakMode: .byWordWrapping)
        let shader = UnlitMaterial(color: .white)
        let textEntity = ModelEntity(mesh: text, materials: [shader])
        textEntity.orientation = simd_quatf(angle: Float.pi + Float.pi/2,
                                            axis: [1, 0, 0])
        buttonEntity.addChild(textEntity)
        textEntity.setPosition([-0.10, 0.026, 0.03], relativeTo: buttonEntity)
        return buttonEntity
    }
    
    func createPauseButton() -> ModelEntity {
        let buttonMesh = MeshResource.generateBox(size: SIMD3<Float>(0.30, 0.05, 0.10), cornerRadius: 10)
        let buttonMaterial = SimpleMaterial(color: .systemBlue, roughness: 0.4, isMetallic: false)
        let buttonEntity = ModelEntity(mesh: buttonMesh, materials: [buttonMaterial])
        buttonEntity.name = "pauseButton"
        let text = MeshResource.generateText("Pause",
                              extrusionDepth: 0,
                                        font: .systemFont(ofSize: 0.07),
                              containerFrame: .zero,
                                   alignment: .center,
                               lineBreakMode: .byWordWrapping)
        let shader = UnlitMaterial(color: .white)
        let textEntity = ModelEntity(mesh: text, materials: [shader])
        textEntity.orientation = simd_quatf(angle: Float.pi + Float.pi/2,
                                            axis: [1, 0, 0])
        buttonEntity.addChild(textEntity)
        textEntity.setPosition([-0.10, 0.026, 0.03], relativeTo: buttonEntity)
        return buttonEntity
    }
    
    func createRestartButton() -> ModelEntity {
        let buttonMesh = MeshResource.generateBox(size: SIMD3<Float>(0.30, 0.05, 0.10), cornerRadius: 10)
        let buttonMaterial = SimpleMaterial(color: .systemBlue, roughness: 0.4, isMetallic: false)
        let buttonEntity = ModelEntity(mesh: buttonMesh, materials: [buttonMaterial])
        buttonEntity.name = "restartButton"
        let text = MeshResource.generateText("Restart",
                              extrusionDepth: 0,
                                        font: .systemFont(ofSize: 0.07),
                              containerFrame: .zero,
                                   alignment: .center,
                               lineBreakMode: .byWordWrapping)
        let shader = UnlitMaterial(color: .white)
        let textEntity = ModelEntity(mesh: text, materials: [shader])
        textEntity.orientation = simd_quatf(angle: Float.pi + Float.pi/2,
                                            axis: [1, 0, 0])
        buttonEntity.addChild(textEntity)
        textEntity.setPosition([-0.10, 0.026, 0.03], relativeTo: buttonEntity)
        return buttonEntity
    }
    
    @IBAction func closeOnClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    // MARK: Hand Interaction

    var recentIndexFingerPoint : CGPoint = .zero
    var viewWidth : Int = 0
    var viewHeight : Int = 0
    var isVideoLoaded : Bool = false

    lazy var request : VNRequest = {
        var handPoseRequest = VNDetectHumanHandPoseRequest(completionHandler: handDetectionCompletionHandler)
        handPoseRequest.maximumHandCount = 1
        return handPoseRequest
    }()

    func handDetectionCompletionHandler(request: VNRequest?, error: Error?) {
        guard let observation = request?.results?.first as? VNHumanHandPoseObservation else { return }
        guard let indexFingerTip = try? observation.recognizedPoints(.all)[.indexTip],
              indexFingerTip.confidence > 0.3 else {return}
        let normalizedIndexPoint = VNImagePointForNormalizedPoint(CGPoint(x: indexFingerTip.location.y, y: indexFingerTip.location.x), viewWidth,  viewHeight)
        if let entity = arView.entity(at: normalizedIndexPoint) as? ModelEntity {
            switch entity.name {
            case "playButton":
                playVideo()
                
            case "pauseButton":
                pauseVideo()
                
            case "restartButton":
                DispatchQueue.main.async {
                    self.restartVideo(for: entity.parent as! ModelEntity)
                }
                
            default: break
                
            }
        }
        recentIndexFingerPoint = normalizedIndexPoint
    }
    
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
    
    // Feedback
    func hapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
}

extension ARView {
        
//    func enableTapOnObject() {
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
//        self.addGestureRecognizer(tapGestureRecognizer)
//    }
//
//    @objc func handleTap(recognizer: UITapGestureRecognizer) {
//        let tapLocation = recognizer.location(in: self)
//        if let entity = self.entity(at: tapLocation) as? ModelEntity, entity.name == "tvScreen" {
//            loadVideoMaterial(for: entity)
//        }
//    }
//
//    func loadVideoMaterial(for entity: ModelEntity) {
//        let asset = AVAsset(url: Bundle.main.url(forResource: "DemoVideo", withExtension: "MOV")!)
//        //let asset = AVAsset(url: URL(string: "https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.mp4")!)
//        let playerItem = AVPlayerItem(asset: asset)
//
//        let player = AVPlayer()
//        entity.model?.materials = [VideoMaterial(avPlayer: player)]
//
//        player.replaceCurrentItem(with: playerItem)
//        player.play()
//    }
    
}

// MARK: ARSessionDelegate
extension ARViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let handler = VNImageRequestHandler(cvPixelBuffer:pixelBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([(self?.request)!])
            } catch let error {
                print(error)
            }
        }
    }
    
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
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        anchors.compactMap { $0 as? ARImageAnchor }.forEach {
            let referenceImage = $0.referenceImage
            guard let imageName = referenceImage.name else { return }
            ProgressController.setProgress(imageName: imageName)
            let plane = MeshResource.generatePlane(width: Float(referenceImage.physicalSize.width), depth: Float(referenceImage.physicalSize.height))
            let material = SimpleMaterial(color: .random, isMetallic: false)
            let entityPlane = ModelEntity(mesh: plane, materials: [material])
            let anchorEntity = AnchorEntity(.image(group: "AR Resources", name: imageName))
            anchorEntity.addChild(entityPlane)
            arView.scene.anchors.removeAll()
            addFocusSquare()
            arView.scene.anchors.append(anchorEntity)
            hapticFeedback()
        }
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

// MARK: FocusEntityDelegate
extension ARViewController: FocusEntityDelegate {
    
    func addFocusSquare() {
        let focusSquare = FocusEntity(on: arView, focus: .classic)
        focusSquare.delegate = self
        arView.scene.anchors.append(focusSquare)
    }
    
    func toInitializingState() {
        //print("Initializing")
    }
    
    func toTrackingState() {
        //print("Tracking")
    }
    
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
