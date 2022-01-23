//
//  CustomScrollView.swift
//  Exchange app-2
//
//  Created by Oleg Shum on 18.01.2022.
//

import UIKit

class CustomScrollView: UIScrollView {
    
    private let pagesCount: CGFloat = 3
    
    let usdBoxView = CustomCurrencyView(label: "USD")
    let eurBoxView = CustomCurrencyView(label: "EUR")
    let gbpBoxView = CustomCurrencyView(label: "GBP")
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [usdBoxView, eurBoxView, gbpBoxView])
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   private func setupScrollView() {
       self.isPagingEnabled = true
       self.showsHorizontalScrollIndicator = false
       self.translatesAutoresizingMaskIntoConstraints = false
       self.addSubview(stackView)
       
       //initialize balance from UserDefaults to views
       gbpBoxView.currentBalance.text = ("\(String(UserDefaults.standard.double(forKey: "gpbBalance")))£")
       usdBoxView.currentBalance.text = ("\(String(UserDefaults.standard.double(forKey: "usdBalance")))$")
       eurBoxView.currentBalance.text = ("\(String(UserDefaults.standard.double(forKey: "eurBalance")))€")
       
        let constraints = [
            contentLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            contentLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            contentLayoutGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
            contentLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            frameLayoutGuide.heightAnchor.constraint(equalTo: contentLayoutGuide.heightAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: pagesCount),
            ]
            NSLayoutConstraint.activate(constraints)
    }
    

    
}
