//
//  ViewController.swift
//  Exchange app-2
//
//  Created by Oleg Shum on 18.01.2022.

// Роберт Мартин по чистой арх.
// collection view
//

import UIKit
import Alamofire


class ViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    //MARK: - setup let/var
    //array for numbers input field (этот массив хранит введенные символы)
    var inputTextField: String?
    
    //current rate to calculate (текущий rate. при запуске одинаковые валюты, поэтому изначально 1.0)
    var currentRate: Double?
    
    //set number of active View (переменная, которая хранит номер активного элемента scrollView. при запуске 1,1)
    var topViewScrollNumber = 1
    var bottomViewScrollNumber = 1
    
    //set current box in view, as object (хранит объект текущего отображаемого View)
    var topBoxView: CustomCurrencyView?
    var bottomBoxView: CustomCurrencyView?
    
//    var structCurrency: Rates? //if we need use rates only
    var dataSource: Data?
    
    private let scrollViewHeight: CGFloat = 150
    
    //create UIScrollView objects
    private let topScrollView = CustomScrollView()
    private let bottomScrollView = CustomScrollView()
    
    
    //params for Alamofire
    private var url = "http://api.exchangeratesapi.io/latest?access_key=7e9f2e1f655a573e5189f16d2cb00a85"
    var timer: DispatchSourceTimer?


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
//        getExchangeRate(url: url) т.к. таймер ниже запускает его
        getRateTimer()
    }
    // MARK: - function setupView
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(topScrollView)
        view.addSubview(bottomScrollView)
        
        topScrollView.usdBoxView.delegate = self
        
        
        //set delegates for input recognize
        topScrollView.delegate = self
        bottomScrollView.delegate = self
        
        topScrollView.usdBoxView.amountTextField.delegate = self
        topScrollView.eurBoxView.amountTextField.delegate = self
        topScrollView.gbpBoxView.amountTextField.delegate = self
        //set tag for topScrollView
        topScrollView.tag = 1
        
        bottomScrollView.usdBoxView.amountTextField.isUserInteractionEnabled = false
        bottomScrollView.eurBoxView.amountTextField.isUserInteractionEnabled = false
        bottomScrollView.gbpBoxView.amountTextField.isUserInteractionEnabled = false
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

        // FIXME: - через switch по тегу выясняем, верхний или нижний элемент скроллится и внутри проверяем, если в результате скролла номер страницы равен номеру страницы с предыдущего скролла - значит перелистывания не произошло и не нужно обнулять данные (нет действий). Если не равен - обнуляем + обновляем номер страницы в переменной. Такая конструкция для проверки - ок?
        
        //FIXME: - Если активировать textField, затем сделать свайп - курсор останется на предыдущем textField и с клавиатуры мака можно писать - это ведь только на симуляторе так?
        switch scrollView.tag {
        case 1:
            if page != topViewScrollNumber {
                // clear textFields, and inputed symbols after any scroll (очищает поле ввода\вывода + очищает введенные символы из хранилища)
                topBoxView?.amountTextField.text = ""
                bottomBoxView?.amountTextField.text = ""
                inputTextField = ""
                topViewScrollNumber = page
            }
        case 2:
            if page != bottomViewScrollNumber {
                topBoxView?.amountTextField.text = ""
                bottomBoxView?.amountTextField.text = ""
                inputTextField = ""
                bottomViewScrollNumber = page
            }

        default:
            return
        }
        
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

        
        
        
        // 2 switch-a, которые перебирают номер текущего отображаемого scrollView сверху и снизу
        switch topViewScrollNumber {
        case 1:
            //USD
            fromRate = self.dataSource?.rates.USD ?? 0 // достает из текущей версии Data рейт валюты
            self.topBoxView = self.topScrollView.usdBoxView // присваивает объект текущего view для того, чтобы присвоить его label-ам значения rate
            topSymbol = "$" // символ валюты, который будет использован для label в title и topBox и bottomBox
        case 2:
            //EUR
            fromRate = self.dataSource?.rates.EUR ?? 0
            self.topBoxView = self.topScrollView.eurBoxView
            topSymbol = "€"

        case 3:
//            let rate = topScrollView.gbpBoxView.exchangeRate.text
            fromRate = self.dataSource?.rates.GBP ?? 0
            self.topBoxView = self.topScrollView.gbpBoxView
            topSymbol = "£"

        default:
            break
        }
        
        switch bottomViewScrollNumber {
        case 1:
            //USD
            toRate = self.dataSource?.rates.USD ?? 0
            self.bottomBoxView = self.bottomScrollView.usdBoxView
            bottomSymbol = "$"
        case 2:
            //EUR
            toRate = self.dataSource?.rates.EUR ?? 0
            self.bottomBoxView = self.bottomScrollView.eurBoxView
            bottomSymbol = "€"

        case 3:
//            let rate = topScrollView.gbpBoxView.exchangeRate.text
            toRate = self.dataSource?.rates.GBP ?? 0
            self.bottomBoxView = self.bottomScrollView.gbpBoxView
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
            self.topBoxView?.exchangeRate.text = "1\(topSymbol) = \(bottomSymbol) \(topViewCourse)"
            self.bottomBoxView?.exchangeRate.text = "1\(bottomSymbol) = \(topSymbol) \(bottomViewCourse)"
            self.title = self.topBoxView?.exchangeRate.text
        }
    }
// MARK: - input recognizer
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("добавлен символ:\(string)")
        if let text = textField.text {
            self.inputTextField = text + string
            print(self.inputTextField)
        }

        convertValue()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text)
    }
    // MARK: - character deletion recognizer
    //FIXME: - нужна функция(?), которая отслеживает удаление символа из поля ввода и изменяет массив
    
    // MARK: - currency convertation
    private func convertValue() {

//        let numberArray: Double
        var result = 0.0

        // unwrap numberArray and currentRate
        if let numberArray = Double(self.inputTextField ?? ""), let currentRate = currentRate {
            result = Double(numberArray) * currentRate
            self.bottomBoxView?.amountTextField.text = String(format: "%.2f", result)
            print(result)
        }
        
        else {
            bottomScrollView.usdBoxView.amountTextField.text = "ОШИБКА"
            print("ОШИБКА введенные данные содержат не корректное значение")
        }

    }
    // MARK: get Data from UserDefaults
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
    //MARK: - Exchange button
    @objc private func exchangeButtonPressed() {
        print("button pressed")
        let alert = UIAlertController(title: "Notification", message: "Lorem Ipsum", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: - Alamofire
    func getExchangeRate(url: String) {
        
        AF.request(url).responseDecodable(of: Data.self) { response in
            switch response.result {
            case .success(let value):
                self.dataSource = value
                //self.structCurrency = value.rates // if we need use rates only
                DispatchQueue.main.async {
                    if self.dataSource != nil {
//                        self.updateUI(dataSource: dataSource)
                        self.changeCurrencyRates()
                    }
                }
            case .failure(let error):
                print("ОШИБКА: \(error)")
            }
        }
    }
    
    //Обновление rates раз в 30 сек
    func getRateTimer() {
        let queue = DispatchQueue(label: "getRate", attributes: .concurrent)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(),
                       repeating: .seconds(300),
                       leeway: .seconds(1))
        timer?.setEventHandler {
            self.getExchangeRate(url: self.url)
            print("rates updated")
        }
        timer?.resume()
    }
    

    
}

extension ViewController: CustomCurrencyViewDelegate {
    func editText(value: String) {
        print("тест2", value)
    }
    
    
}
