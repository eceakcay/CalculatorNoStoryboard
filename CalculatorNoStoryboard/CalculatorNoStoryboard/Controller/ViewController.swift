//
//  ViewController.swift
//  CalculatorNoStoryboard
//
//  Created by Ece Akcay on 12.08.2025.
//

import UIKit

class ViewController: UIViewController {
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .right
        label.textColor = .white
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var currentNumber: String = "0"
    private var previousNumber: String = ""
    private var operation: String = ""
    private var isPerformingOperation: Bool = false
    private var justCalculated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setupUI()
    }
    
    private func createButton(title: String, color: UIColor = .gray, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func setupUI() {
        view.addSubview(resultLabel)
        view.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultLabel.heightAnchor.constraint(equalToConstant: 100),
            
            buttonsStackView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        let rows = [
            ["C", "±", "%", "/"],
            ["7", "8", "9", "*"],
            ["4", "5", "6", "-"],
            ["1", "2", "3", "+"],
            ["0", ".", "="]
        ]
        
        for row in rows {
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.distribution = .fillEqually
            horizontalStack.spacing = 10
            
            for title in row {
                let color: UIColor = (title == "C" || title == "=" || title == "±" || title == "%") ? .orange : (["+", "-", "*", "/"].contains(title) ? .lightGray : .gray)
                let action: Selector = (title == "C") ? #selector(clearButtonTapped) :
                (title == "±") ? #selector(toggleSignButtonTapped) :
                (title == "%") ? #selector(percentButtonTapped) :
                (title == "=") ? #selector(calculateButtonTapped) :
                (["+", "-", "*", "/"].contains(title)) ? #selector(operationButtonTapped(_:)) :
                #selector(numberButtonTapped(_:))
                
                let button = createButton(title: title, color: color, action: action)
                horizontalStack.addArrangedSubview(button)
                
                if title == "=" {
                    button.widthAnchor.constraint(equalTo: horizontalStack.widthAnchor, multiplier: 0.5, constant: -5).isActive = true
                }
            }
            buttonsStackView.addArrangedSubview(horizontalStack)
        }
    }
    
    @objc private func numberButtonTapped(_ sender: UIButton) {
        guard let number = sender.currentTitle else { return }
        
        // "=" sonrası yeni sayı giriliyorsa temizle
        if justCalculated {
            currentNumber = (number == ".") ? "0." : number
            justCalculated = false
            resultLabel.text = currentNumber
            return
        }
        
        if number == "." {
            if !currentNumber.contains(".") {
                currentNumber += number
            }
        } else if currentNumber == "0" || isPerformingOperation {
            currentNumber = number
            isPerformingOperation = false
        } else {
            currentNumber += number
        }
        resultLabel.text = currentNumber
    }
    
    @objc private func operationButtonTapped(_ sender: UIButton) {
        guard let op = sender.currentTitle else { return }
        
        // Art arda işlem desteği
        if !previousNumber.isEmpty && !isPerformingOperation {
            calculateButtonTapped()
            previousNumber = currentNumber
        } else {
            previousNumber = currentNumber
        }
        
        operation = op
        isPerformingOperation = true
        justCalculated = false
    }
    
    @objc private func calculateButtonTapped() {
        guard !previousNumber.isEmpty, !operation.isEmpty else { return }
        
        let prev = Double(previousNumber) ?? 0
        let curr = Double(currentNumber) ?? 0
        var result: Double = 0
        
        switch operation {
        case "+": result = prev + curr
        case "-": result = prev - curr
        case "*": result = prev * curr
        case "/": result = (curr != 0) ? prev / curr : 0
        default: break
        }
        
        currentNumber = formatNumber(result)
        
        resultLabel.text = currentNumber
        previousNumber = ""
        operation = ""
        isPerformingOperation = false
        justCalculated = true
    }
    
    @objc private func clearButtonTapped() {
        currentNumber = "0"
        previousNumber = ""
        operation = ""
        isPerformingOperation = false
        justCalculated = false
        resultLabel.text = "0"
    }
    
    @objc private func toggleSignButtonTapped() {
        if let currentValue = Double(currentNumber), currentValue != 0 {
            currentNumber = formatNumber(currentValue * -1)
            resultLabel.text = currentNumber
        }
    }
    
    @objc private func percentButtonTapped() {
        if let currentValue = Double(currentNumber), currentValue != 0 {
            currentNumber = formatNumber(currentValue / 100)
            resultLabel.text = currentNumber
        }
    }
    
    // Sayı formatlama: en fazla 5 basamak, gereksiz sıfır yok
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 5
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
