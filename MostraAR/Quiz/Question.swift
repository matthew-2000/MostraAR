//
//  Question.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 23/05/22.
//

import Foundation

class Question {
    
    var question: String
    var answers: [String]
    var correct: String
    
    init(question: String, answers: [String], correct: String) {
        self.question = question
        self.answers = answers
        self.correct = correct
    }
    
    func isCorrect(answer: String) -> Bool {
        return correct == answer
    }
    
}
