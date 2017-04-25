//
//  SymbolTableViewController.swift
//  Bulls & Bears
//
//  Created by Dylan Simerly on 4/23/17.
//  Copyright © 2017 dylansimerly. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SymbolTableViewController: YahooFinanceViewController {
    
    static let identifier = "SymbolTableViewController"
    
    @IBOutlet var symbolTableView: UITableView!
    
    var viewModel: SymbolViewModel!
    
    override func viewDidLoad() {
        self.viewModel = self
        self.setSymbolTableView()
        self.showSymbolTableView()
    }
    
    func setSymbolTableView() {
        self.symbolTableView.rx.modelSelected(Result.self).subscribe { (event:Event<Result>) in
            if let symbol = event.element?.symbol {
                self.viewModel.queryQuote(symbol)
            }
            }.addDisposableTo(disposeBag)
    }
    
    func showSymbolTableView() {
        let results = Variable(self.viewModel.results)
        results.asObservable().bind(to: self.symbolTableView.rx.items(cellIdentifier: SymbolTableViewCell.reuseIdentifier, cellType: SymbolTableViewCell.self)) { (row, element, cell) in
            cell.nameLabel.text = (element.name ?? "")
            cell.symbolLabel.text = (element.symbol ?? "")
            }.addDisposableTo(disposeBag)
    }
}

extension SymbolTableViewController: SymbolViewModel {
    
    func refreshUI() {
        self.showSymbolTableView()
    }
    
    func showLoading() {
        self.showLoadingView()
    }
    
    func hideLoading() {
        self.hideLoadingView()
    }
    
    func queryQuoteSuccess(quotes: [Quote]) {
        let quoteTableViewController = self.mainStoryboard.instantiateViewController(withIdentifier: QuoteTableViewController.identifier) as! QuoteTableViewController
        QuoteViewModelData.sharedData.quotes = quotes
        self.navigationController?.pushViewController(quoteTableViewController, animated: true)
    }
    
    func queryQuoteFail(error: NSError?) {
        self.showPopup(title: (error?.code != nil ? String(error!.code) : ""), message: self.viewModel.getTexts(.failMessage), completionHandler: { (complete) in
            
        })
    }
    
}

