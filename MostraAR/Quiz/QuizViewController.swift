//
//  QuizViewController.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 23/05/22.
//

import UIKit

class QuizViewController: UIViewController {
    
    @IBOutlet weak var answerCollectionView: UICollectionView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var questionArray = [Question(question: "Quanto fa 2+2?", answers: ["2", "4", "10", "3"], correct: "4"),
                         Question(question: "Quanto fa 2+3?", answers: ["2", "4", "10", "5"], correct: "5"),
                         Question(question: "Quanto fa 3+3?", answers: ["2", "4", "6", "37"], correct: "6"),
                         Question(question: "Quanto fa 12+23?", answers: ["25", "22", "35", "3"], correct: "35")]
    var currentQuestionIndex = 0
    var numberCorrectAnswer = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        answerCollectionView.allowsMultipleSelection = true
        answerCollectionView.delegate = self
        answerCollectionView.dataSource = self
        
        setUpView()
    }
    
    func setUpView() {
        answerCollectionView.allowsSelection = true
        
        let currentQuestion = questionArray[currentQuestionIndex]
        numberLabel.text = "\(currentQuestionIndex+1)/\(questionArray.count)"
        questionLabel.text = currentQuestion.question
        
        answerCollectionView.indexPathsForSelectedItems?
            .forEach { answerCollectionView.deselectItem(at: $0, animated: false) }
        answerCollectionView.reloadData()

        nextButton.isHidden = true
        
    }
    
    @IBAction func nextOnClick(_ sender: Any) {
        currentQuestionIndex += 1
        if currentQuestionIndex < questionArray.count {
            setUpView()
        } else {
            finishQuiz()
        }
    }
    
    func finishQuiz() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FinishViewControllerID") as! FinishViewController
        viewController.numberCorrectAnswer = numberCorrectAnswer
        viewController.numberQuestion = questionArray.count
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

extension QuizViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questionArray[currentQuestionIndex].answers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnswerCellID", for: indexPath) as! AnswerCell
        cell.setCell(answer: questionArray[currentQuestionIndex].answers[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AnswerCell
        nextButton.isHidden = false
        if questionArray[currentQuestionIndex].isCorrect(answer: questionArray[currentQuestionIndex].answers[indexPath.row]) {
            cell.setWin()
            numberCorrectAnswer += 1
        } else {
            cell.setLose()
        }
        answerCollectionView.allowsSelection = false
    }
    
}
