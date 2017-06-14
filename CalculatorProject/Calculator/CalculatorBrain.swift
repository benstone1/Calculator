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
    
    private enum Operation {
        case constant(Double)
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
                if (state != .isUnary) && state != .isConstant {
                    accumulator.val = value
                    accumulator.description += symbol
                    state = .isConstant
                }
            case .unaryOperation(let function):
                if accumulator.val != nil {
                    if pendingBinaryOperation != nil {
                        switch state {
                        case .clear, .isBinary, .isConstant:
                            accumulator.description = accumulator.description + symbol + "(" + String(accumulator.val!) + ")"
                        case .isUnary:
                            accumulator.description = accumulator.description + ")"
                            var indexOfLastOperatorSymbol = 0
                            for (i,c) in accumulator.description.characters.enumerated() {
                                if let c = operations[String(c)]  {
                                    switch c{
                                    case .binaryOperation:
                                        indexOfLastOperatorSymbol = i
                                    default:
                                        break
                                    }
                                }
                            }
                            accumulator.description = accumulator.description.substring(to: accumulator.description.index(accumulator.description.startIndex, offsetBy: indexOfLastOperatorSymbol + 1)) + symbol + "(" + accumulator.description.substring(from: accumulator.description.index(accumulator.description.startIndex, offsetBy: indexOfLastOperatorSymbol + 2))
                            
                        }
                    } else {
                        var includeAccumulatorVal = false
                        switch state {
                        case .isBinary, .isUnary, .isConstant:
                            includeAccumulatorVal = false
                        case .clear:
                            includeAccumulatorVal = true
                        }
                        accumulator.description = symbol + "(" + accumulator.description + (includeAccumulatorVal ? String(accumulator.val!) : "") + ")"
                        //accumulator.description = "\(symbol)(\(accumulator.description)\(!(completedABinaryOperation || mostRecentOperationIsUnary) ? String(accumulator.val!) : ""))"
                    }
                    accumulator.val = function(accumulator.val!)
                    state = .isUnary
                }
            case .binaryOperation(let function):
                if accumulator.val != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.val!)
                    var includeAccumulatorVal = false
                    switch state {
                    case .isBinary, .isConstant, .isUnary:
                        includeAccumulatorVal = false
                    case .clear:
                        includeAccumulatorVal = true
                    }
                    accumulator.description += (includeAccumulatorVal ? String(accumulator.val!) : "") + String(symbol)
                    //accumulator.description += (!(completedABinaryOperation || mostRecentOperationIsUnary || mostRecentOperationIsSymbol) ? String(accumulator.val!) : "") + String(symbol)
                    accumulator.val = nil
                    state = .isBinary
                }
            case .equals:
                performPendingBinaryOperation()
            case .clear:
                accumulator = (0, "")
                state = .clear
            }
        }
    }
    
    mutating private func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.val != nil {
            var includeAccumulatorVal = false
            switch state {
            case .isConstant, .isUnary:
                includeAccumulatorVal = false
            case .clear, .isBinary:
                includeAccumulatorVal = true
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
        //accumulator.val = named
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
