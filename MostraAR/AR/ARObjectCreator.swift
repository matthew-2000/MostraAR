//
//  ARObjectCreator.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 01/06/22.
//

import Foundation
import ARKit
import RealityKit

class ARObjectCreator {
    
    static func createPlayButton() -> ModelEntity {
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
    
    static func createPauseButton() -> ModelEntity {
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
    
    static func createRestartButton() -> ModelEntity {
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
    
}
