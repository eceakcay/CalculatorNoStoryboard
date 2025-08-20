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
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        
        // Gölge efekti ekle
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        
        // Gradient arka plan ekle
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        gradientLayer.cornerRadius = 25
        
        switch color {
        case .orange:
            gradientLayer.colors = [UIColor.systemOrange.cgColor, UIColor.orange.cgColor]
        case .gray:
            gradientLayer.colors = [UIColor.systemGray.cgColor, UIColor.gray.cgColor]
        case .darkGray:
            gradientLayer.colors = [UIColor.systemGray2.cgColor, UIColor.darkGray.cgColor]
        default:
            gradientLayer.colors = [color.cgColor, color.cgColor]
        }
        
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Hover efekti için
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.layer.shadowOpacity = 0.1
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity
            sender.layer.shadowOpacity = 0.3
        }
    }
    
    private func setupUI() {
        // Gradient arka plan ekle
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0).cgColor,
            UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Logo ekle
        let logoLabel = UILabel()
        logoLabel.text = "🧮"
        logoLabel.font = UIFont.systemFont(ofSize: 32)
        logoLabel.textAlignment = .center
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoLabel)
        
        view.addSubview(resultLabel)
        view.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            resultLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 30),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultLabel.heightAnchor.constraint(equalToConstant: 100),
            
            buttonsStackView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 30),
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
        
        for row in rows {
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.distribution = .fillEqually
            horizontalStack.spacing = 12
            
            for title in row {
                let color: UIColor = (title == "C" || title == "=" || title == "±" || title == "%") ? .orange : (["+", "−", "×", "÷"].contains(title) ? .systemBlue : .systemGray3)
                let action: Selector = (title == "C") ? #selector(clearButtonTapped) :
                (title == "±") ? #selector(toggleSignButtonTapped) :
                (title == "%") ? #selector(percentButtonTapped) :
                (title == "=") ? #selector(calculateButtonTapped) :
                (["+", "−", "×", "÷"].contains(title)) ? #selector(operationButtonTapped(_:)) :
                #selector(numberButtonTapped(_:))
                
                let button = createButton(title: title, color: color, action: action)
                horizontalStack.addArrangedSubview(button)
                
                if title == "=" {
                    button.widthAnchor.constraint(equalTo: horizontalStack.widthAnchor, multiplier: 0.5, constant: -6).isActive = true
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
        
        // 🔹 FİX: justCalculated flag'ini sıfırla
        justCalculated = false
        
        // Art arda işlem desteği: önceki işlem varsa önce onu hesapla
        if !previousNumber.isEmpty && !operation.isEmpty && !isPerformingOperation {
            calculateButtonTapped()
        }
        
        // 🔹 FİX: previousNumber'ı her zaman currentNumber'dan al
        previousNumber = currentNumber
        operation = convertDisplayToOperation(op)
        isPerformingOperation = true
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
        
        // 🔹 FİX: İşlem sonrası state'i temizle, sadece justCalculated flag'ini set et
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
    // Görsel sembolleri işlem sembollerine çevir
    private func convertDisplayToOperation(_ displaySymbol: String) -> String {
        switch displaySymbol {
        case "÷": return "/"
        case "×": return "*"
        case "−": return "-"
        case "+": return "+"
        default: return displaySymbol
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
