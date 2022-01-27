//
//  CustomCurrencyView.swift
//  Exchange app-2
//
//  Created by Oleg Shum on 18.01.2022.
//

import UIKit

protocol CustomCurrencyViewDelegate: AnyObject {
    func editText(value: String)
}

class CustomCurrencyView: UIView {
    var currencyName = UILabel()
    var currentBalance = UILabel()
    var exchangeRate = UILabel()
    var amountTextField = UITextField()
    
    var currencyLabel: String
    var delegate: CustomCurrencyViewDelegate?
    
//TODO: задать обязательные параметры
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
    
    init(label: String) {
        self.currencyLabel = label
        super.init(frame: CGRect())
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        layer.cornerRadius = 15
        
        // currencyName setup
        currencyName.text = self.currencyLabel
        currencyName.font = UIFont(name: "Futura-CondensedMedium", size: 80)
        currencyName.textColor = .black
        currencyName.translatesAutoresizingMaskIntoConstraints = false
        
        //currentBalance setup
//        currentBalance.text = "You have: 100$"
        currentBalance.font = UIFont(name: "Futura-CondensedMedium", size: 20)
        currentBalance.textColor = .black
        currentBalance.translatesAutoresizingMaskIntoConstraints = false
        
        //excchangeRate setup
//        exchangeRate.text = "$1 = $1"
        exchangeRate.font = UIFont(name: "Futura-CondensedMedium", size: 20)
        exchangeRate.textColor = .black
        exchangeRate.translatesAutoresizingMaskIntoConstraints = false
        
        //textFieldValue setup
        amountTextField.placeholder = "0.00"
        amountTextField.font = UIFont(name: "Futura-CondensedMedium", size: 80)
        amountTextField.textColor = .black
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.textAlignment = .right
        amountTextField.keyboardType = .numberPad
        // addTarget
//        amountTextField.addTarget(self, action: #selector(ViewController.textField(_:shouldChangeCharactersIn:replacementString:)), for: .valueChanged)
        //test:
        amountTextField.addTarget(self, action: #selector(printTextValue(_:)), for: .editingChanged)

        
        addSubview(currencyName)
        addSubview(currentBalance)
        addSubview(exchangeRate)
        addSubview(amountTextField)
        
        let constraints = [
            currencyName.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            currencyName.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 100),
            currencyName.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            
            currentBalance.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            currentBalance.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            
            exchangeRate.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            exchangeRate.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            
            amountTextField.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            amountTextField.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        
    }
    
    @objc func printTextValue(_ textField: UITextField) {
        print("тест", textField.text)
        delegate?.editText(value: textField.text ?? "")
    }
    
}
