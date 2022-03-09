//
//  MainModel.swift
//  ExchangeTestBlanc
//
//  Created by Alexander on 03/03/2022.
//  Copyright © 2022 ExchangeTestBlanc. All rights reserved.
//

import UIKit

protocol MainViewInterface: AnyObject {
    func updateBothsCollections()
    func updateBottomCurrency(currency: Currency, amount: Decimal)
}

protocol MainPresenterInterface: AnyObject {
    func setDependency(_ viewer: MainViewInterface)
    func handleSwipeOfCurrency(newIndex1: Int, newIndex2: Int)
    func exchangeMoney(completion: (_ alert: UIAlertController) -> Void)
    func getData(completion: @escaping (String) -> Void)
    func getRateAsText(cur1Index: Int, cur2Index: Int) -> String
}

protocol MainInteractorInterface: AnyObject {
    func getDataFromNetwork(completion: @escaping (Currency?, [Currency]) -> Void)
}

struct NetworkResponse: Codable {
    let success: Bool
    let timestamp: Int
    let base: String
    let date: String
    let rates: [String: Decimal]
}

struct Currency {
    let type: String
    var amount: Decimal
    let rateToBaseCurrency: Decimal
    
    init(type: String, rateToBaseCurrency: Decimal) {
        self.type = type
        self.rateToBaseCurrency = rateToBaseCurrency
        let defaults = UserDefaults.standard
        if let amountString = defaults.string(forKey: type), let amountDouble = Decimal(string: amountString) {
            self.amount = amountDouble
        } else {
            self.amount = 100
            defaults.set("100", forKey: type)
        }
    }
}

