//
//  MainNetworkServices.swift
//  ExchangeTestBlanc
//
//  Created by Alexander on 03/03/2022.
//  Copyright © 2022 ExchangeTestBlanc. All rights reserved.
//

import UIKit

typealias JSONCompletionHandler = (Data?, Error?) -> Void

class NetworkService {
    
    // В рамках тестового приложения с одним запросом пишу URL одной строкой, храня API key прямо в коде. Указание параметра base и использование HTTPS недоступно в базовом плане подписки
    let urlString = "http://api.exchangeratesapi.io/v1/latest?access_key=06d99973ac081288d05efd23c656a5e9&symbols=USD,GBP"
    
    func fetchNetworkData(completion: @escaping JSONCompletionHandler) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                completion(data, error)
            }
        }.resume()
    }
}
