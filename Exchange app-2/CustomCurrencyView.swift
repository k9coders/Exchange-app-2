//
//  CustomCurrencyView.swift
//  Exchange app-2
//
//  Created by Oleg Shum on 18.01.2022.
//

import UIKit

class CustomCurrencyView: UIView {
    var currencyName = UILabel()
    var currentBalance = UILabel()
    var exchangeRate = UILabel()
    var textFieldValue = UITextField()
    
    var currencyLabel: String
    
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
        currentBalance.text = "You have: 100$"
        currentBalance.font = UIFont(name: "Futura-CondensedMedium", size: 20)
        currentBalance.textColor = .black
        currentBalance.translatesAutoresizingMaskIntoConstraints = false
        
        //excchangeRate setup
        exchangeRate.text = "$1 = $1"
        exchangeRate.font = UIFont(name: "Futura-CondensedMedium", size: 20)
        exchangeRate.textColor = .black
        exchangeRate.translatesAutoresizingMaskIntoConstraints = false
        
        //textFieldValue setup
        textFieldValue.placeholder = "0.00"
        textFieldValue.font = UIFont(name: "Futura-CondensedMedium", size: 80)
        textFieldValue.textColor = .black
        textFieldValue.translatesAutoresizingMaskIntoConstraints = false
        textFieldValue.textAlignment = .right
        textFieldValue.keyboardType = .numberPad
        // addTarget
//        textFieldValue.addTarget(self, action: #selector(ViewController.textFieldDidChangeValue(textField:)), for: .editingChanged)

        
        addSubview(currencyName)
        addSubview(currentBalance)
        addSubview(exchangeRate)
        addSubview(textFieldValue)
        
        let constraints = [
            currencyName.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            currencyName.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 100),
            currencyName.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            
            currentBalance.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            currentBalance.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            
            exchangeRate.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            exchangeRate.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            
            textFieldValue.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            textFieldValue.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        
    }
    
}
