//
//  ARViewController+ARSessionDelegate.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 01/06/22.
//

import UIKit
import ARKit
import RealityKit
import FocusEntity

extension ARViewController: ARSessionDelegate {
    
    // MARK: Hand Interaction
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([(self?.request)!])
            } catch let error {
                print(error)
            }
        }
    }

    func handDetectionCompletionHandler(request: VNRequest?, error: Error?) {
        guard let observation = request?.results?.first as? VNHumanHandPoseObservation else { return }
        guard let indexFingerTip = try? observation.recognizedPoints(.indexFinger)[.indexTip],
              indexFingerTip.confidence > 0.3 else {return}
        let normalizedIndexPoint = VNImagePointForNormalizedPoint(CGPoint(x: indexFingerTip.location.y, y: indexFingerTip.location.x), viewWidth,  viewHeight)
        if let entity = arView.entity(at: normalizedIndexPoint) as? ModelEntity  {
            if !isRunning {
                isRunning = true
                switch entity.name {
                case "playButton":
                    playVideo()
                    
                case "pauseButton":
                    pauseVideo()
                    
                case "restartButton":
                    DispatchQueue.main.async {
                        self.restartVideo(for: entity.parent as! ModelEntity)
                    }
                    
                case "album":
                    DispatchQueue.main.async {
                        self.changeImage(entity: entity)
                    }
                    
                default: break
                    
                }
            }
        }
        recentIndexFingerPoint = normalizedIndexPoint
    }
    
    func changeImage(entity: ModelEntity) {
        numAlbumImage += 1
        if numAlbumImage == 6 {
            numAlbumImage = 1
        }
        var material = SimpleMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.999), texture: .init(try! .load(named: "album\(numAlbumImage)")))
        entity.model?.materials = [material]
    }
    
    //MARK: Debugging
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
    
    //MARK: Progress and Image recognition
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        anchors.compactMap { $0 as? ARImageAnchor }.forEach {
            let referenceImage = $0.referenceImage
            guard let imageName = referenceImage.name else { return }
            if imageName == "anchor" {
                let plane = MeshResource.generatePlane(width: Float(referenceImage.physicalSize.width), depth: Float(referenceImage.physicalSize.height))
                var material = SimpleMaterial()
                material.color = .init(tint: .white.withAlphaComponent(0.999), texture: .init(try! .load(named: "album\(numAlbumImage)")))
                let entityPlane = ModelEntity(mesh: plane, materials: [material])
                entityPlane.name = "album"
                let anchorEntity = AnchorEntity(.image(group: "AR Resources", name: imageName))
                anchorEntity.addChild(entityPlane)
                entityPlane.generateCollisionShapes(recursive: true)
                arView.scene.anchors.removeAll()
                //addFocusSquare()
                arView.scene.anchors.append(anchorEntity)
            } else {
                ProgressController.setProgress(imageName: imageName)
                let plane = MeshResource.generatePlane(width: Float(referenceImage.physicalSize.width), depth: Float(referenceImage.physicalSize.height))
                let material = SimpleMaterial(color: .random, isMetallic: false)
                let entityPlane = ModelEntity(mesh: plane, materials: [material])
                let anchorEntity = AnchorEntity(.image(group: "AR Resources", name: imageName))
                anchorEntity.addChild(entityPlane)
                arView.scene.anchors.removeAll()
                //addFocusSquare()
                arView.scene.anchors.append(anchorEntity)
                hapticFeedback()
            }
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
