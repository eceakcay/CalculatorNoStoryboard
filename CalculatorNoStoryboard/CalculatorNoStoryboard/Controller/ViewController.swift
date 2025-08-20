//
//  ViewController.swift
//  CalculatorNoStoryboard
//
//  Created by Ece Akcay on 12.08.2025.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Components
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 58, weight: .bold) // daha kalın
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
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    private var currentNumber: String = "0"
    private var previousNumber: String = ""
    private var operation: String = ""
    private var isPerformingOperation: Bool = false
    private var justCalculated: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
    }
    
    // MARK: - UI Setup
    private func createButton(title: String, color: UIColor = .gray, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 26, weight: .bold) // buton yazısı biraz küçültüldü
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Touch efektleri
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 0.5
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 1.0
        }
    }
    
    private func setupUI() {
        view.addSubview(resultLabel)
        view.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultLabel.heightAnchor.constraint(equalToConstant: 120),
            
            buttonsStackView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        let rows = [
            ["C", "±", "%", "÷"],
            ["7", "8", "9", "×"],
            ["4", "5", "6", "−"],
            ["1", "2", "3", "+"],
            ["0", ".", "="]
        ]
        
        for (rowIndex, row) in rows.enumerated() {
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.distribution = .fillEqually
            horizontalStack.spacing = 8
            
            if rowIndex == 4 { // Son satır (0, ., =)
                let zeroButton = createButton(
                    title: "0",
                    color: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0),
                    action: #selector(numberButtonTapped(_:))
                )
                
                let dotButton = createButton(
                    title: ".",
                    color: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0),
                    action: #selector(numberButtonTapped(_:))
                )
                
                let equalsButton = createButton(
                    title: "=",
                    color: .systemOrange,
                    action: #selector(calculateButtonTapped)
                )
                
                horizontalStack.addArrangedSubview(zeroButton)
                horizontalStack.addArrangedSubview(dotButton)
                horizontalStack.addArrangedSubview(equalsButton)
                
                // "0" butonunu daha geniş yap (2 birim genişlik)
                zeroButton.widthAnchor.constraint(equalTo: dotButton.widthAnchor, multiplier: 2, constant: 8).isActive = true
                
            } else {
                for title in row {
                    var color: UIColor
                    
                    // Buton renkleri aynı kaldı
                    if title == "C" || title == "±" || title == "%" {
                        color = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) // Açık gri
                    } else if ["+", "−", "×", "÷", "="].contains(title) {
                        color = .systemOrange // Turuncu
                    } else {
                        color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Koyu gri
                    }
                    
                    let action: Selector =
                        (title == "C") ? #selector(clearButtonTapped) :
                        (title == "±") ? #selector(toggleSignButtonTapped) :
                        (title == "%") ? #selector(percentButtonTapped) :
                        (title == "=") ? #selector(calculateButtonTapped) :
                        (["+", "−", "×", "÷"].contains(title)) ? #selector(operationButtonTapped(_:)) :
                        #selector(numberButtonTapped(_:))
                    
                    let button = createButton(title: title, color: color, action: action)
                    
                    if ["+", "−", "×", "÷", "="].contains(title) {
                        button.setTitleColor(.white, for: .normal)
                    } else if title == "C" || title == "±" || title == "%" {
                        button.setTitleColor(.black, for: .normal)
                    }
                    
                    horizontalStack.addArrangedSubview(button)
                }
            }
            buttonsStackView.addArrangedSubview(horizontalStack)
        }
    }
    
    // MARK: - Button Actions
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
        
        // Reset all operator button colors
        resetOperatorButtonColors()
        
        // Highlight selected operator
        sender.backgroundColor = .white
        sender.setTitleColor(.systemOrange, for: .normal)
        
        justCalculated = false
        
        // Art arda işlem: önceki işlem varsa önce onu hesapla
        if !previousNumber.isEmpty && !operation.isEmpty && !isPerformingOperation {
            calculateButtonTapped()
        }
        
        previousNumber = currentNumber
        operation = convertDisplayToOperation(op)
        isPerformingOperation = true
    }
    
    private func resetOperatorButtonColors() {
        // Tüm operatör butonlarını varsayılan rengine döndür
        for subview in buttonsStackView.arrangedSubviews {
            if let stackView = subview as? UIStackView {
                for button in stackView.arrangedSubviews {
                    if let btn = button as? UIButton,
                       let title = btn.currentTitle,
                       ["+", "−", "×", "÷"].contains(title) {
                        btn.backgroundColor = .systemOrange
                        btn.setTitleColor(.white, for: .normal)
                    }
                }
            }
        }
    }
    
    @objc private func calculateButtonTapped() {
        guard !previousNumber.isEmpty, !operation.isEmpty else { return }
        
        resetOperatorButtonColors()
        
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
        
        operation = ""
        previousNumber = ""
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
        resetOperatorButtonColors()
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
    
    // MARK: - Helper Methods
    private func convertDisplayToOperation(_ displaySymbol: String) -> String {
        switch displaySymbol {
        case "÷": return "/"
        case "×": return "*"
        case "−": return "-"
        case "+": return "+"
        default: return displaySymbol
        }
    }
    
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        formatter.numberStyle = .decimal
        
        // Çok büyük sayılar için bilimsel notasyon
        if abs(value) >= 1e9 {
            formatter.numberStyle = .scientific
            formatter.maximumFractionDigits = 2
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
