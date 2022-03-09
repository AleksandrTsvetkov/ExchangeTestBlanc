//
//  MainConfigurator.swift
//  ExchangeTestBlanc
//
//  Created by Александр Цветков on 06.03.2022.
//

import Foundation

class MainConfigurator {

    private var presenter: MainPresenterInterface
    
    init() {
        let interactor = MainInteractor()
        self.presenter = MainPresenter(dataSource: interactor)
    }
    
    func getDataSource() -> MainPresenterInterface {
        
        return self.presenter
    }
    
}
