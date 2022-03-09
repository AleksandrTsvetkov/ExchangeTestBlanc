//
//  Extensions.swift
//  ExchangeTestBlanc
//
//  Created by Александр Цветков on 07.03.2022.
//

import Foundation

extension Decimal {

    func rounded(toPlaces places: Int) -> String {
        let divisor = pow(10.0, Double(places))
        let newSelf = NSDecimalNumber(decimal: self).doubleValue
        let resultOfRounding = round(newSelf * divisor) / divisor
        return "\(resultOfRounding)"
    }
}
