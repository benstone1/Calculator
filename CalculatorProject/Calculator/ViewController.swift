//
//  ViewController.swift
//  Calculator
//
//  Created by C4Q  on 5/3/17.
//  Copyright © 2017 C4Q . All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustButtonLayout(for: view, isPortrait: traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular, isStartUp: true)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        adjustButtonLayout(for: view, isPortrait: traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular, isStartUp: false)
    }
    
    private func adjustButtonLayout(for view: UIView, isPortrait: Bool, isStartUp: Bool) {
        for subview in view.subviews {
            if subview.tag == 1 {
                subview.isHidden = !isStartUp ? isPortrait : !isPortrait
            } else if subview.tag == 2 {
                subview.isHidden = !isStartUp ? !isPortrait : isPortrait
            }
            if let stack = subview as? UIStackView {
                adjustButtonLayout(for: stack, isPortrait: isPortrait, isStartUp: isStartUp)
            }
        }
    }
    
    @IBOutlet weak var display: UILabel!
    var userIsTyping = false
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set  {
            display.text = String(newValue)
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle
        if userIsTyping {
            if !(display.text!.contains(".") && digit == ".") {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + digit!
                
            }
        } else {
            display.text = digit!
            userIsTyping = true
        }
    }
    
    @IBOutlet weak var userInputs: UILabel!
    
    private var brain = CalculatorBrain()
    
    private var variableDict = [String: Double]()
    
    @IBOutlet weak var variableLabel: UILabel!
    
    private func displayResult() {
        let evaluated = brain.evaluate(using: variableDict)
        
        if let result = evaluated.result {
            displayValue = result
        }
        userInputs.text = evaluated.description
        let textCurrentlyInDisplay = userInputs.text!
        if brain.isPending {
            userInputs.text = textCurrentlyInDisplay + "..."
        } else {
            userInputs.text = textCurrentlyInDisplay + "="
        }
    }
    
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false
        }
        if let validSymbol = sender.currentTitle {
            brain.performOperation(validSymbol)
        }
        displayResult()
    }
    
    @IBAction func reset(_ sender: UIButton) {
        brain = CalculatorBrain()
        displayValue = 0
        userInputs.text = " "
        userIsTyping = false
        variableDict = [:]
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if userIsTyping {
            if let textSoFar = display.text {
                var newText = textSoFar.substring(to: textSoFar.index(textSoFar.startIndex, offsetBy: textSoFar.characters.count - 1))
                if newText.isEmpty || newText == "0" {
                    userIsTyping = false
                    newText = "0"
                }
                display.text = newText
            }
        } else {
            brain.undo()
            displayResult()
        }
    }
    
    @IBAction func storeVariable(_ sender: UIButton) {
        variableDict["M"] = displayValue
        //variableDict.updateValue(displayValue, forKey: "M")
        userIsTyping = false
        variableLabel.text = "M = " + String(displayValue)
        displayResult()
    }
    @IBAction func useVariable(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        userIsTyping = false
        displayResult()
    }
}


