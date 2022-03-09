//
//  MainInteractor.swift
//  ExchangeTestBlanc
//
//  Created by Alexander on 03/03/2022.
//  Copyright © 2022 ExchangeTestBlanc. All rights reserved.
//

import UIKit

class MainInteractor: MainInteractorInterface {

    let networkService = NetworkService()
    
    func getDataFromNetwork(completion: @escaping (Currency?, [Currency]) -> Void) {
        networkService.fetchNetworkData { [weak self] data, error in
            guard let data = data else {
                completion(nil, [])
                return
            }
            if let error = error {
                print(#file, #line, error.localizedDescription)
                completion(nil, [])
                return
            }
            let decoder = JSONDecoder()
            do {
                let networkResponse = try decoder.decode(NetworkResponse.self, from: data)
                self?.createCurrenciesFromResponse(networkResponse, completion: completion)
                return
            } catch {
                print(#file, #line, error.localizedDescription)
                completion(nil, [])
                return
            }
        }
    }
    
    private func createCurrenciesFromResponse(_ response: NetworkResponse, completion: @escaping (Currency, [Currency]) -> Void) {
        let baseCurrency = Currency(type: response.base, rateToBaseCurrency: 1)
        var currencies: Array<Currency> = [baseCurrency]
        for rate in response.rates {
            let baseRate = rate.value
            var newRate: Decimal = 0
            if baseRate != 0 {
                newRate = 1 / baseRate
            }
            let currency = Currency(type: rate.key, rateToBaseCurrency: newRate)
            currencies.append(currency)
        }
        completion(baseCurrency, currencies.sorted(by: { $0.type < $1.type }))
    }
    
}
