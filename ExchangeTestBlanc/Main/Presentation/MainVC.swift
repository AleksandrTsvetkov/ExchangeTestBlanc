//
//  MainVC.swift
//  ExchangeTestBlanc
//
//  Created by Alexander on 03/03/2022.
//  Copyright © 2022 ExchangeTestBlanc. All rights reserved.
//

import UIKit

class MainVC: UIViewController, MainViewInterface {

    //MARK: - Properties
    private var presenter: MainPresenterInterface?
    private var timer: Timer?
    private var foregroundObserver: NSObjectProtocol?
    private var backgroundObserver: NSObjectProtocol?
    
    //MARK: - Subviews
    private var topCollectionView: UICollectionView?
    private var bottomCollectionView: UICollectionView?
    private let invisibleTextField: UITextField = {
        let view = UITextField()
        view.isHidden = true
        view.keyboardType = .decimalPad
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let exchangeRateLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 1
        view.isHidden = true
        view.font = UIFont.systemFont(ofSize: 21, weight: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let arrowImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .systemBlue
        view.image = UIImage(named: "tradeArrow")
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let exchangeButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isHidden = true
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 20
        let font = UIFont.systemFont(ofSize: 20, weight: .medium)
        let attrTitle = NSAttributedString(string: "Обменять", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: font])
        view.setAttributedTitle(attrTitle, for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        self.presenter = MainConfigurator().getDataSource()
        self.presenter?.setDependency(self)
        topCollectionView = createCollectionView()
        topCollectionView?.tag = 0
        bottomCollectionView = createCollectionView()
        bottomCollectionView?.tag = 1
        exchangeButton.addTarget(self, action: #selector(exchangeTapped), for: .touchUpInside)
        setupSubviews()
        startTimer()
        invisibleTextField.delegate = self.presenter as? UITextFieldDelegate
        foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.startTimer()
        }
        backgroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.timer?.invalidate()
            self?.timer = nil
        }
    }
    
    //MARK: - Setup methods
    private func setupSubviews() {
        guard let topCollection = topCollectionView, let bottomCollection = bottomCollectionView else { return }
        view.addSubview(exchangeRateLabel)
        view.addSubview(topCollection)
        view.addSubview(invisibleTextField)
        view.addSubview(bottomCollection)
        view.addSubview(arrowImageView)
        view.addSubview(exchangeButton)
        
        var topPadding: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            topPadding = window?.safeAreaInsets.top ?? 0
        } else if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window?.safeAreaInsets.top ?? 0
        }
        
        NSLayoutConstraint.activate([
            exchangeRateLabel.heightAnchor.constraint(equalToConstant: 26),
            exchangeRateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: topPadding + 15),
            exchangeRateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            exchangeRateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            invisibleTextField.topAnchor.constraint(equalTo: topCollection.topAnchor),
            invisibleTextField.bottomAnchor.constraint(equalTo: topCollection.bottomAnchor),
            invisibleTextField.leadingAnchor.constraint(equalTo: topCollection.leadingAnchor),
            invisibleTextField.trailingAnchor.constraint(equalTo: topCollection.trailingAnchor),
            
            topCollection.topAnchor.constraint(equalTo: exchangeRateLabel.bottomAnchor, constant: 14),
            topCollection.heightAnchor.constraint(equalToConstant: 80),
            topCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            arrowImageView.heightAnchor.constraint(equalToConstant: 60),
            arrowImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arrowImageView.topAnchor.constraint(equalTo: topCollection.bottomAnchor, constant: 10),
            
            bottomCollection.topAnchor.constraint(equalTo: arrowImageView.bottomAnchor, constant: 10),
            bottomCollection.heightAnchor.constraint(equalToConstant: 80),
            bottomCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            exchangeButton.topAnchor.constraint(equalTo: bottomCollection.bottomAnchor, constant: 14),
            exchangeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exchangeButton.widthAnchor.constraint(equalToConstant: 150),
            exchangeButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    private func startTimer() {
        updateExchangeRates()
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateExchangeRates), userInfo: nil, repeats: true)
        }
    }
    
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        // Страница занимает всю ширину поэтому подойдёт встроенная пейджинация
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self.presenter as? UICollectionViewDataSource
        collectionView.register(CurrencyCVC.self, forCellWithReuseIdentifier: CurrencyCVC.reuseId)
        return collectionView
    }
    
    @objc private func updateExchangeRates() {
        self.presenter?.getData { [weak self] rateTextRepresentation in
            self?.exchangeRateLabel.text = rateTextRepresentation
            self?.exchangeRateLabel.isHidden = false
            self?.arrowImageView.isHidden = false
            self?.exchangeButton.isHidden = false
            self?.topCollectionView?.reloadData()
            self?.bottomCollectionView?.reloadData()
        }
    }
    
    //MARK: - Handle user events
    @objc func exchangeTapped() {
        self.presenter?.exchangeMoney(completion: { alert in
            invisibleTextField.text = nil
            invisibleTextField.resignFirstResponder()
            self.updateBothsCollections()
            self.present(alert, animated: true)
        })
    }
    
    func updateBothsCollections() {
        self.topCollectionView?.reloadData()
        self.bottomCollectionView?.reloadData()
    }
    
    func updateBottomCurrency(currency: Currency, amount: Decimal) {
        if let visibleCell = self.topCollectionView?.visibleCells.first as? CurrencyCVC {
            visibleCell.configure(with: currency, amount: amount)
        }
        self.bottomCollectionView?.reloadData()
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MainVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard
            let topIndex = topCollectionView?.indexPathsForVisibleItems.first,
            let bottomIndex = bottomCollectionView?.indexPathsForVisibleItems.first
        else { return }
        self.exchangeRateLabel.text = self.presenter?.getRateAsText(cur1Index: topIndex.item, cur2Index: bottomIndex.item)
        self.presenter?.handleSwipeOfCurrency(newIndex1: topIndex.item, newIndex2: bottomIndex.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if collectionView.tag == 0 {
            invisibleTextField.becomeFirstResponder()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
}
