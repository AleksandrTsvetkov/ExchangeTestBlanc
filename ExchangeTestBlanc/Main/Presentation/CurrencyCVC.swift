//
//  CurrencyCVC.swift
//  ExchangeTestBlanc
//
//  Created by Александр Цветков on 04.03.2022.
//

import UIKit

class CurrencyCVC: UICollectionViewCell {
    
    static let reuseId = String(describing: CurrencyCVC.self)
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let amountLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = UIFont.systemFont(ofSize: 20)
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let currencyLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let exchangeLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .right
        view.tintColor = .white
        view.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var currency: Currency?
    var customConstraints: Array<NSLayoutConstraint> = []
    
    func configure(with currency: Currency, amount: Decimal) {
        self.currency = currency
        if amount != 0 {
            exchangeLabel.text = amount.rounded(toPlaces: 4)
        } else {
            exchangeLabel.text = "0.00"
        }
        currencyLabel.text = "\(currency.type)".uppercased()
        amountLabel.text = "\(currency.amount.rounded(toPlaces: 4))"
    }
    
    func setupSubviews() {
        addSubview(mainView)
        mainView.addSubview(currencyLabel)
        mainView.addSubview(amountLabel)
        mainView.addSubview(exchangeLabel)
        
        if customConstraints.isEmpty {
            customConstraints = [
                mainView.topAnchor.constraint(equalTo: self.topAnchor),
                mainView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                mainView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
                mainView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
                
                currencyLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10),
                currencyLabel.bottomAnchor.constraint(equalTo: amountLabel.topAnchor),
                currencyLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10),
                currencyLabel.trailingAnchor.constraint(equalTo: exchangeLabel.leadingAnchor, constant: -10),
                
                amountLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -10),
                amountLabel.leadingAnchor.constraint(equalTo: currencyLabel.leadingAnchor),
                amountLabel.trailingAnchor.constraint(equalTo: currencyLabel.trailingAnchor),
                
                exchangeLabel.topAnchor.constraint(equalTo: currencyLabel.topAnchor),
                exchangeLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -10),
                exchangeLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            ]
        }
        
        NSLayoutConstraint.activate(customConstraints)
    }
}
