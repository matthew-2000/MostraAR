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
            
            // With vibration
            let systemSoundID: SystemSoundID = 1113
            AudioServicesPlaySystemSound(systemSoundID)
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
