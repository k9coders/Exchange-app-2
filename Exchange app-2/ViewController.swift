//
//  ViewController.swift
//  Exchange app-2
//
//  Created by Oleg Shum on 18.01.2022.
//

import UIKit
import Alamofire


class ViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    //MARK: - setup let/var
    //array for numbers input field (этот массив хранит введенные символы)
    var arrayTextField: [String] = []
    
    //current rate to calculate (текущий rate. при запуске одинаковые валюты, поэтому изначально 1.0)
    var currentRate = 1.0
    
    //set number of active View (переменная, которая хранит номер активного элемента scrollView. при запуске 1,1)
    var topViewScrollNumber = 1
    var bottomViewScrollNumber = 1
    
//    var structCurrency: Rates? //if we need use rates only
    var dataSource: Data?
    
    private let scrollViewHeight: CGFloat = 150
    
    //create UIScrollView objects
    private let topScrollView = CustomScrollView()
    private let bottomScrollView = CustomScrollView()
    
    
    //params for Alamofire
    private var url = "http://api.exchangeratesapi.io/latest?access_key=d7b9466fd5bb4b76efb769f0ec8f61d4"

    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //(отрисовка UI, delegates, constraints)
        setupView()
        
        //is first start app? if true - set start balance
        userDefaults()
        
        //setup Exchange button
        let exchangeButton = UIBarButtonItem(title: "Exchange", style: .plain, target: self, action: #selector(exchangeButtonPressed))
        navigationItem.rightBarButtonItem = exchangeButton
        
        // (получить курсы валют при запуске приложения)
        getExchangeRate(url: url)
    }
    // MARK: - function setupView
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(topScrollView)
        view.addSubview(bottomScrollView)
        
        //set delegates for input recognize
        topScrollView.delegate = self
        bottomScrollView.delegate = self
        
        topScrollView.usdBoxView.textFieldValue.delegate = self
        topScrollView.eurBoxView.textFieldValue.delegate = self
        topScrollView.gbpBoxView.textFieldValue.delegate = self
        //set tag for topScrollView
        topScrollView.tag = 1
        
        bottomScrollView.usdBoxView.textFieldValue.isUserInteractionEnabled = false
        bottomScrollView.eurBoxView.textFieldValue.isUserInteractionEnabled = false
        bottomScrollView.gbpBoxView.textFieldValue.isUserInteractionEnabled = false
        //set tag for bottomScrollView
        bottomScrollView.tag = 2
        
        let constraints = [
            topScrollView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            topScrollView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            topScrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            topScrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight),
            
            bottomScrollView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            bottomScrollView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            bottomScrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 250),
            bottomScrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
    //MARK: - Define the current View
    // calculate scrollView page numbers
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width + 1)
        if scrollView.tag == 1 {
            print("слайд: \(page)")
            print("верхний сладер")
            topViewScrollNumber = page
        }
        else {
//            let page = Int(bottomScrollView.contentOffset.x / scrollView.frame.size.width + 1)
            print("слайд: \(page)")
            print("нижний слайдер")
            bottomViewScrollNumber = page
        }
        changeCurrencyRates()
    }
    //MARK: - Calculate currency rates
    //Change currency rates in title and label
    func changeCurrencyRates() {
        
        var fromRate = 0.0 //rate валюты, которая находится на верхнем UIScrollView
        var toRate = 0.0 //rate валюты, которая находится на нижнем UIScrollView
        
        var topSymbol = "" //символ валюты, которая находится на верхнем UIScrollView
        var bottomSymbol = "" //символ валюты, которая находится на нижнем UIScrollView

        //FIXME: - возможно объект topBox стоит сделать глобальным, чтобы из другой функции (конвертация) всегда иметь доступ к текущему View
        
        var topBox: CustomCurrencyView? // объект верхнего UIScrollView
        var bottomBox: CustomCurrencyView?
        
        
        // 2 switch-a, которые перебирают номер текущего отображаемого scrollView сверху и снизу
        switch topViewScrollNumber {
        case 1:
            //USD
            fromRate = self.dataSource?.rates.USD ?? 0 // достает из текущей версии Data рейт валюты
            topBox = self.topScrollView.usdBoxView // присваивает объект текущего view для того, чтобы присвоить его label-ам значения rate
            topSymbol = "$" // символ валюты, который будет использован для label в title и topBox и bottomBox
        case 2:
            //EUR
            fromRate = self.dataSource?.rates.EUR ?? 0
            topBox = self.topScrollView.eurBoxView
            topSymbol = "€"

        case 3:
//            let rate = topScrollView.gbpBoxView.exchangeRate.text
            fromRate = self.dataSource?.rates.GBP ?? 0
            topBox = self.topScrollView.gbpBoxView
            topSymbol = "£"

        default:
            break
        }
        
        switch bottomViewScrollNumber {
        case 1:
            //USD
            toRate = self.dataSource?.rates.USD ?? 0
            bottomBox = self.bottomScrollView.usdBoxView
            bottomSymbol = "$"
        case 2:
            //EUR
            toRate = self.dataSource?.rates.EUR ?? 0
            bottomBox = self.bottomScrollView.eurBoxView
            bottomSymbol = "€"

        case 3:
//            let rate = topScrollView.gbpBoxView.exchangeRate.text
            toRate = self.dataSource?.rates.GBP ?? 0
            bottomBox = self.bottomScrollView.gbpBoxView
            bottomSymbol = "£"

        default:
            break
            }
        //Calculate actual rate

        let topViewCourse = String(format: "%.2f",toRate/fromRate) //rate для валюты, которая выбрана в верхнем scrollView, считается относительно выбранной валюты в нижем scrollView
        let bottomViewCourse = String(format: "%.2f",fromRate/toRate) //rate для валюты, которая выбрана в нижнем scrollView
        currentRate = toRate/fromRate

        //Update UI
        DispatchQueue.main.async {
            //update rate to title and labels
            topBox?.exchangeRate.text = "1\(topSymbol) = \(bottomSymbol) \(topViewCourse)"
            bottomBox?.exchangeRate.text = "1\(bottomSymbol) = \(topSymbol) \(bottomViewCourse)"
            self.title = topBox?.exchangeRate.text
        }
    }
// MARK: - input recognizer
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("добавлен символ:\(string)")
        
        arrayTextField.append(string)
        convertValue(array: arrayTextField)
        
        return true
    }
    // convertation
    private func convertValue(array: [String]){

        //FIXME: это корректно? Привожу тип [String] в String, иначе он не переводится в Double для математической операции
        let numberArray = array.joined(separator: "")
        var result = 0.0
//        for i in array{
//            numberArray += i
////            result = Double(numberArray)! * currentRate
////            bottomScrollView.usdBoxView.textFieldValue.text = String(format: "%.2f", result)
////            print(result)
//        }
        
        // unwrap numberArray
        if let numberArray = Double(numberArray) {
            result = Double(numberArray) * currentRate
            bottomScrollView.usdBoxView.textFieldValue.text = String(format: "%.2f", result)
            print(result)
        }
        else {
            bottomScrollView.usdBoxView.textFieldValue.text = "ОШИБКА введенные данные содержат не корректное значение"
            print("ОШИБКА введенные данные содержат не корректное значение")
        }

    }
    
    func userDefaults() {
        // set start user balance, if app starting first time
        let balance = UserDefaults.standard.bool(forKey: "isFirstStart")
        if balance == false {
            UserDefaults.standard.set(100.0, forKey: "usdBalance")
            UserDefaults.standard.set(100.0, forKey: "eurBalance")
            UserDefaults.standard.set(100.0, forKey: "gpbBalance")
            UserDefaults.standard.set(true, forKey: "isFirstStart")
        }
        
        //set balances from UserDefoults
        DispatchQueue.main.async {
        self.topScrollView.usdBoxView.currentBalance.text = String(UserDefaults.standard.double(forKey: "usdBalance"))
        self.topScrollView.eurBoxView.currentBalance.text = String(UserDefaults.standard.double(forKey: "eurBalance"))
        self.topScrollView.eurBoxView.currentBalance.text = String(UserDefaults.standard.double(forKey: "gpbBalance"))
        
        self.bottomScrollView.usdBoxView.currentBalance.text = String(UserDefaults.standard.double(forKey: "usdBalance"))
        self.bottomScrollView.eurBoxView.currentBalance.text = String(UserDefaults.standard.double(forKey: "eurBalance"))
        self.bottomScrollView.eurBoxView.currentBalance.text = String(UserDefaults.standard.double(forKey: "gpbBalance"))
        }
    }
    
    @objc private func exchangeButtonPressed() {
        print("button pressed")
        let alert = UIAlertController(title: "Notification", message: "Lorem Ipsum", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getExchangeRate(url: String) {
        
        AF.request(url).responseDecodable(of: Data.self) { response in
            switch response.result {
            case .success(let value):
                print("value: \(value)")
                print(value.rates)
                self.dataSource = value
                //self.structCurrency = value.rates // if we need use rates only
                DispatchQueue.main.async {
                    if let dataSource = self.dataSource {
                        self.updateUI(dataSource: dataSource)
//                        self.title = String(value.rates.USD)
                    }
                }
            case .failure(let error):
                print("ОШИБКА: \(error)")
                
            }
        }
    }
    
    // update UILabels to actual rates
    private func updateUI(dataSource: Data) {
//        self.title = "\(dataSource.rates.USD)"
        //FIXME: - берется EUR rate который присваивается "текущему rate", которым при запуске приложения является USD. Фактически т.к. при запуске выбраны валюты USD:USD - их rate 1
        currentRate = dataSource.rates.EUR
        print("title: \(self.title)")
        // вызываем метод, который обновляет
        changeCurrencyRates()
    }
}
