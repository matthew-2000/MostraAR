//
//  ImageARController.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 19/05/22.
//

import Foundation

class ProgressController {
    
    static let numberOfImages = 5.0
    
    static func setProgress(imageName: String) {
        if UserDefaults.standard.string(forKey: imageName) == nil {
            UserDefaults.standard.set(imageName, forKey: imageName)
            var progressPercentage = UserDefaults.standard.double(forKey: "progress")
            progressPercentage += 1/numberOfImages
            print(progressPercentage)
            UserDefaults.standard.set(progressPercentage, forKey: "progress")
        }
    }
    
    static func getProgress() -> Double {
        return UserDefaults.standard.double(forKey: "progress")
    }
    
    static func resetProgress() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
}
