//
//  FinishViewController.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 23/05/22.
//

import UIKit

class FinishViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var numberCorrectAnswer = 0
    var numberQuestion = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        scoreLabel.text = "Your score is \(numberCorrectAnswer)/\(numberQuestion)"
        
    }
    
    @IBAction func goHome(_ sender: Any) {
        let vc = self.presentingViewController
        self.dismiss(animated: true, completion: {
            vc?.dismiss(animated: true)
        })
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
