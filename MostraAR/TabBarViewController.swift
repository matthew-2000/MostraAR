//
//  TabBarViewController.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 16/05/22.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.barTintColor = .white
        
        //setupTabBar()
        
    }
    
//    func setupTabBar() {
//
//        var yValue = 20
//        var topValue = -11.5
//        var bottomValue = 11.5
//
//        if UIScreen.main.bounds.height < 670 {
//            yValue = 30
//            topValue = -21.5
//            bottomValue = 21.5
//        }
//
//        let layer = CAShapeLayer()
//        layer.path = UIBezierPath(roundedRect: CGRect(x: 25, y: tabBar.bounds.minY - CGFloat(yValue), width: tabBar.bounds.width - 50, height: 67), cornerRadius: 21).cgPath
//        layer.shadowColor = UIColor.gray.cgColor
//        layer.shadowRadius = 5
//        layer.shadowOpacity = 0.3
//        layer.shadowOffset = .zero
//        layer.borderWidth = 1.0
//        layer.opacity = 1.0
//        layer.isHidden = false
//        layer.masksToBounds = false
//        layer.fillColor = UIColor.white.cgColor
//
//        tabBar.backgroundImage = UIImage()
//        tabBar.shadowImage = UIImage()
//        tabBar.backgroundColor = .white
//        tabBar.itemWidth = 40
//        tabBar.itemSpacing = (tabBar.bounds.width - 250)/5
//        tabBar.itemPositioning = .fill
//
//        tabBar.layer.insertSublayer(layer, at: 0)
//
//        if let items = tabBar.items {
//            items.forEach { item in
//                item.imageInsets = UIEdgeInsets(top: CGFloat(topValue), left: 10, bottom: CGFloat(bottomValue), right: 10);
//
//            }
//        }
//
//    }

}

