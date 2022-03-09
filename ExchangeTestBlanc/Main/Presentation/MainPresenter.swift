//
//  MainPresenter.swift
//  ExchangeTestBlanc
//
//  Created by Alexander on 03/03/2022.
//  Copyright © 2022 ExchangeTestBlanc. All rights reserved.
//

import UIKit

class MainPresenter: NSObject, MainPresenterInterface {

    private weak var viewer: MainViewInterface?
    private var interactor: MainInteractorInterface!
    private var currencies: Array<Currency> = []
    private var baseCurrency: Currency?
    private var topAmount: Decimal = 0
    private var bottomAmount: Decimal = 0
    let stringToCompare = "0123456789."
    var lastUsedIndexes = (0, 0)

    init(dataSource interactor: MainInteractorInterface?) {
        self.interactor = interactor
    }
    
    func getData(completion: @escaping (String) -> Void) {
        self.interactor.getDataFromNetwork { [weak self] baseCurrency, currencies  in
            self?.baseCurrency = baseCurrency
            self?.currencies = currencies
            let cur1Index = self?.lastUsedIndexes.0 ?? 0
            let cur2Index = self?.lastUsedIndexes.1 ?? 0
            completion(self?.getRateAsText(cur1Index: cur1Index, cur2Index: cur2Index) ?? "")
        }
    }
    
    func getRateAsText(cur1Index: Int, cur2Index: Int) -> String {
        self.lastUsedIndexes = (cur1Index, cur2Index)
        guard !currencies.isEmpty else { return "" }
        let cur1 = currencies[cur1Index]
        let cur2 = currencies[cur2Index]
        var rateBetweenCurrencies: Decimal = 0
        if cur2.rateToBaseCurrency != 0 {
            rateBetweenCurrencies = cur1.rateToBaseCurrency / cur2.rateToBaseCurrency
        }
        let rateString = rateBetweenCurrencies.rounded(toPlaces: 4)
        return "1 \(cur1.type) = \(rateString) \(cur2.type)"
    }
    
    func setDependency(_ viewer: MainViewInterface) {
        self.viewer = viewer
    }
    
    func handleSwipeOfCurrency(newIndex1: Int, newIndex2: Int) {
        var newBottomAmount: Decimal = 0
        if currencies[newIndex2].rateToBaseCurrency != 0 {
            newBottomAmount = topAmount * currencies[newIndex1].rateToBaseCurrency / currencies[newIndex2].rateToBaseCurrency
        }
        bottomAmount = newBottomAmount
        viewer?.updateBothsCollections()
    }
    
    func countRateAndCallUpdate(_ stringForUpdate: String) {
        let decimalAmount = Decimal(string: stringForUpdate) ?? 0
        var newBottomAmount: Decimal = 0
        if currencies[lastUsedIndexes.1].rateToBaseCurrency != 0 {
            newBottomAmount = decimalAmount * currencies[lastUsedIndexes.0].rateToBaseCurrency / currencies[lastUsedIndexes.1].rateToBaseCurrency
        }
        topAmount = decimalAmount
        bottomAmount = newBottomAmount
        self.viewer?.updateBottomCurrency(currency: currencies[lastUsedIndexes.0], amount: decimalAmount)
    }
    
    func exchangeMoney(completion: (_ alert: UIAlertController) -> Void) {
        guard topAmount > 0 else {
            return
        }
        
        guard lastUsedIndexes.0 != lastUsedIndexes.1 else { return }
        guard currencies[lastUsedIndexes.0].amount - topAmount >= 0 else {
            let alert = UIAlertController(title: "Ошибка", message: "Недостаточно средств", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
            completion(alert)
            return
        }
        
        let defaults = UserDefaults.standard
        currencies[lastUsedIndexes.0].amount -= topAmount
        topAmount = 0
        currencies[lastUsedIndexes.1].amount += bottomAmount
        bottomAmount = 0
        defaults.set("\(currencies[lastUsedIndexes.0].amount)", forKey: currencies[lastUsedIndexes.0].type)
        defaults.set("\(currencies[lastUsedIndexes.1].amount)", forKey: currencies[lastUsedIndexes.1].type)
        
        let alert = UIAlertController(title: "Успешно", message: "Изменения баланса отражены в карточках", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        completion(alert)
    }
}

//MARK: - UICollectionViewDataSource
extension MainPresenter: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyCVC.reuseId, for: indexPath) as! CurrencyCVC
        if collectionView.tag == 0 {
            cell.configure(with: currencies[indexPath.row], amount: topAmount)
        } else {
            cell.configure(with: currencies[indexPath.row], amount: bottomAmount)
        }
        cell.setupSubviews()
        return cell
    }
}

//MARK: - UITextFieldDelegate
extension MainPresenter: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        if updatedString.first == "." {
            return false
        }
        if updatedString.filter({ stringToCompare.contains($0) }).isEmpty {
            return false
        }
        if updatedString.filter({ $0 == "." }).count > 1 {
            return false
        }
        self.countRateAndCallUpdate(updatedString)
        return true
    }
}
