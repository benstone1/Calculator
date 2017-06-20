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
    private var state: Operation = .clear
    
    private var variables = [String: Double]()
    
    private enum Input {
        case operand(Double)
        case variable(String)
        case operation(String)
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double,Double) -> Double, (String, String) -> String)
        case equals
        case clear
    }
    
    private var operations: Dictionary<String, Operation> = [
        "C": Operation.clear,
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt, {"√(" + $0 + ")"}),
        "ln": Operation.unaryOperation(log, {"ln(" + $0 + ")"}),
        "log": Operation.unaryOperation(log10, {"log(" + $0 + ")"}),
        "sin": Operation.unaryOperation(sin, {"sin(" + $0 + ")"}),
        "cos": Operation.unaryOperation(cos, {"cos(" + $0 + ")"}),
        "tan": Operation.unaryOperation(tan, {"tan(" + $0 + ")"}),
        "sinh": Operation.unaryOperation(sinh, {"sinh(" + $0 + ")"}),
        "cosh": Operation.unaryOperation(cosh, {"cosh(" + $0 + ")"}),
        "tanh": Operation.unaryOperation(tanh, {"tanh(" + $0 + ")"}),
        "x²": Operation.unaryOperation({$0*$0}, {"(" + $0 + ")²"}),
        "x³": Operation.unaryOperation({$0*$0*$0}, {"(" + $0 + ")³"}),
        "eˣ": Operation.unaryOperation(exp, {"e^(" + $0 + ")"}),
        "10ˣ": Operation.unaryOperation({pow(10,$0)}, {"10^(" + $0 + ")"}),
        "x!": Operation.unaryOperation(factorial, {"(" + $0 + ")!"}),
        "x⁻¹": Operation.unaryOperation({1/$0}, {"(" + $0 + ")⁻¹"}),
        "±": Operation.unaryOperation({-$0}, {"-(" + $0 + ")"}),
        "×": Operation.binaryOperation({$0*$1}, {$0 + "×" + $1}),
        "÷": Operation.binaryOperation({$0/$1}, {$0 + "÷" + $1}),
        "−": Operation.binaryOperation({$0-$1}, {$0 + "−" + $1}),
        "+": Operation.binaryOperation({$0+$1}, {$0 + "+" + $1}),
        "xʸ": Operation.binaryOperation({pow($0,$1)}, {$0 + "^(" + $1 + ")"}),
        "=": Operation.equals
    ]
    
    private var stack = [Input]()
    
    mutating func setOperand(_ operand: Double) {
        stack.append(Input.operand(operand))
    }
    mutating func setOperand(variable named: String) {
        stack.append(Input.variable(named))
    }
    mutating func performOperation(_ symbol: String) {
        stack.append(Input.operation(symbol))
    }
    
    mutating func undo() {
        if !stack.isEmpty {
            stack.removeLast()
        }
    }
    
    func evaluate(using variables: [String: Double]? = nil) -> (result: Double?, isPending: Bool, description: String) {
        var accumulator: (val: Double, description: String)? = nil
        var pendingBinaryOperation: PendingBinaryOperation?
        
        struct PendingBinaryOperation {
            let function: (Double, Double) -> Double
            let firstOperand: (val: Double, description: String)
            let descriptionFunction: (String, String) -> String
            func perform(with secondOperand: (Double, String)) -> (val: Double, description: String) {
                return (function(firstOperand.val, secondOperand.0), descriptionFunction(firstOperand.description, secondOperand.1))
            }
        }
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator = pendingBinaryOperation!.perform(with: (accumulator!))
                pendingBinaryOperation = nil
            }
        }
        
        var result: Double? {
            return accumulator?.val
        }
        
        var description: String? {
            if pendingBinaryOperation != nil {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.firstOperand.description, accumulator?.description ?? "")
            }
            return accumulator?.description
        }
        
        for operation in stack {
            switch operation {
            case .operation(let symbol):
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        accumulator = (value, symbol)
                    case .unaryOperation(let function, let descriptionFunction):
                        if let currentVal = accumulator?.val, let currentDescription = accumulator?.description {
                            accumulator = (function(currentVal), descriptionFunction(currentDescription))
                        }
                    case .binaryOperation(let function, let descriptionFunction):
                        performPendingBinaryOperation()
                        if accumulator != nil {
                            pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction)
                            accumulator = nil
                        }
                    case .equals:
                        performPendingBinaryOperation()
                    case .clear:
                        accumulator = nil
                    }
                }
            case .operand(let value):
                accumulator = (value, String(value))
            case .variable(let str):
                if let value = variables?[str] {
                    accumulator = (value, str)
                } else {
                    accumulator = (0, str)
                }
            }
        }
        return (result, pendingBinaryOperation != nil, description ?? "")
    }
    
    var result: Double? {
        return evaluate().result
    }
    var isPending: Bool {
        return evaluate().isPending
    }
    var description: String {
        return evaluate().description
    }
    
}
