//
//  AnswerCell.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 23/05/22.
//

import UIKit

class AnswerCell: UICollectionViewCell {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var labelAnswer: UILabel!
    
    override func prepareForReuse() {
        cardView.layoutSubviews()
        labelAnswer.textColor = .label
    }
    
    func setCell(answer: String) {
        labelAnswer.text = answer
    }
    
    func setWin() {
        cardView.backgroundColor = .green
        labelAnswer.textColor = .white
    }
    
    func setLose() {
        labelAnswer.textColor = .white
        cardView.backgroundColor = .red
    }
    
}
