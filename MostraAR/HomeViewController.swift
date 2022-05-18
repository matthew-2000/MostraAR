//
//  HomeViewController.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 16/05/22.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var progressdView: CircularProgressBarView!
    var circularViewDuration: TimeInterval = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCircularProgressBarView()
    }
    
    func setUpCircularProgressBarView() {
        let percentage = 0.4
        progressdView.progressAnimation(duration: circularViewDuration, withPercentage: percentage)
    }

    @IBAction func openARView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ARViewControllerID") as! ARViewController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
