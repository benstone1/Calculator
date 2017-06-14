//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by C4Q  on 5/31/17.
//  Copyright © 2017 C4Q . All rights reserved.
//

import Foundation

func factorial(_ n: Double) -> Double {
    if n <= 1 {
        return 1.0
    }
    return n * factorial(n - 1)
}

struct CalculatorBrain {
    
    var description: String {
        get {
            return accumulator.description
        }
    }
    
    private var accumulator: (val: Double?, description: String) = (nil, "")
    
    private enum MostRecentOperation {
        case clear
        case isConstant
        case isUnary
        case isBinary
    }
    
    private var state: MostRecentOperation = .clear
    private var state2: Operation = .clear
    
    private enum Operation {
        case constant(Double)
        case operand(Double)
        case variable(String)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
        case clear
    }
    
    private var operations: Dictionary<String, Operation> = [
        "C": Operation.clear,
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "ln": Operation.unaryOperation(log),
        "log": Operation.unaryOperation(log10),
        "sin": Operation.unaryOperation(sin),
        "cos": Operation.unaryOperation(cos),
        "tan": Operation.unaryOperation(tan),
        "sinh": Operation.unaryOperation(sinh),
        "cosh": Operation.unaryOperation(cosh),
        "tanh": Operation.unaryOperation(tanh),
        "x²": Operation.unaryOperation({$0*$0}),
        "x³": Operation.unaryOperation({$0*$0*$0}),
        "eˣ": Operation.unaryOperation(exp),
        "10ˣ": Operation.unaryOperation({pow(10,$0)}),
        "x!": Operation.unaryOperation(factorial),
        "x⁻¹": Operation.unaryOperation({1/$0}),
        "±": Operation.unaryOperation({-$0}),
        "×": Operation.binaryOperation({$0*$1}),
        "÷": Operation.binaryOperation({$0/$1}),
        "−": Operation.binaryOperation({$0-$1}),
        "+": Operation.binaryOperation({$0+$1}),
        "xʸ": Operation.binaryOperation({pow($0,$1)}),
        "=": Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                switch state2 {
                case .unaryOperation, .constant:
                    break
                default:
                    accumulator.val = value
                    accumulator.description += symbol
                    state2 = .constant(value)
                }
                /*
                if (state != .isUnary) && state != .isConstant {
                    accumulator.val = value
                    accumulator.description += symbol
                    //state = .isConstant
                    state2 = .constant(value)
                }
                */
            case .unaryOperation(let function):
                if accumulator.val != nil {
                    updateDescription(symbol)
                    accumulator.val = function(accumulator.val!)
                    //state = .isUnary
                    state2 = .unaryOperation(function)
                }
            case .binaryOperation(let function):
                if accumulator.val != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.val!)
                    switch state2 {
                    case .clear:
                        accumulator.description += String(accumulator.val!) + String(symbol)
                    default:
                        accumulator.description += "" + String(symbol)

                    }
                    /*
                    accumulator.description += (state == .clear ? String(accumulator.val!) : "") + String(symbol)
                    accumulator.val = nil
                    //state = .isBinary
                     */
                    state2 = .binaryOperation(function)
                }
            case .equals:
                performPendingBinaryOperation()
            case .clear:
                accumulator = (0, "")
                state = .clear
                state2 = .clear
            default:
                break
            }
        }
    }
    
    mutating private func updateDescription(_ symbol: String) {
        if pendingBinaryOperation != nil {
            switch state2 {
            case .clear, .binaryOperation, .constant:
                accumulator.description = accumulator.description + symbol + "(" + String(accumulator.val!) + ")"
            case .unaryOperation:
                accumulator.description = accumulator.description + ")"
                let indexOfLastOperatorSymbol = findLastOperatorSymbolIndex()
                accumulator.description = accumulator.description.substring(to: accumulator.description.index(accumulator.description.startIndex, offsetBy: indexOfLastOperatorSymbol + 1)) + symbol + "(" + accumulator.description.substring(from: accumulator.description.index(accumulator.description.startIndex, offsetBy: indexOfLastOperatorSymbol + 2))
            default:
                break
            }
            
            /*
            switch state {
            case .clear, .isBinary, .isConstant:
                accumulator.description = accumulator.description + symbol + "(" + String(accumulator.val!) + ")"
            case .isUnary:
                accumulator.description = accumulator.description + ")"
                let indexOfLastOperatorSymbol = findLastOperatorSymbolIndex()
                accumulator.description = accumulator.description.substring(to: accumulator.description.index(accumulator.description.startIndex, offsetBy: indexOfLastOperatorSymbol + 1)) + symbol + "(" + accumulator.description.substring(from: accumulator.description.index(accumulator.description.startIndex, offsetBy: indexOfLastOperatorSymbol + 2))
            }
            */
            
        } else {
            switch state2 {
            case .clear:
                accumulator.description = symbol + "(" + accumulator.description + String(accumulator.val!) + ")"
            default:
                accumulator.description = symbol + "(" + accumulator.description + "" + ")"

            }
            //accumulator.description = symbol + "(" + accumulator.description + (state == .clear ? String(accumulator.val!) : "") + ")"
        }
    }
    
    private func findLastOperatorSymbolIndex() -> Int {
        var indexOfLastOperatorSymbol = 0
        for (i,c) in accumulator.description.characters.enumerated() {
            if let c = operations[String(c)]  {
                switch c {
                case .binaryOperation:
                    indexOfLastOperatorSymbol = i
                default:
                    break
                }
            }
        }
        return indexOfLastOperatorSymbol
    }
    
    mutating private func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.val != nil {
            //let includeAccumulatorVal = (state == .clear || state == .isBinary)
            var includeAccumulatorVal = false
            switch state2 {
            case .clear, .binaryOperation:
                includeAccumulatorVal = true
            default:
                break
            }
            accumulator.description += includeAccumulatorVal ? String(accumulator.val!) : ""
            accumulator.val = pendingBinaryOperation!.perform(with: accumulator.val!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator.val = operand
    }
    
    mutating func setOperand(variable named: String) {
        //stack.append(Input.variable(named))
    }
    
    
    func evaluate(using variables: [String: Double]? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        return (0,false, "")
    }
    
    var result: Double? {
        get {
            return accumulator.val
        }
    }
}
