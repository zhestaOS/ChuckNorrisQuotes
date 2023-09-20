//
//  AllQuotesController.swift
//  ChuckNorrisQuotes
//
//  Created by Евгения Шевякова on 19.09.2023.
//

import UIKit

class AllQuotesController: UITableViewController {
    
    var quotes: [Quote]!
    
    var quotesManager = QuotesManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if quotes == nil {
            quotes = quotesManager.quotes
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        var config = UIListContentConfiguration.cell()
        config.text = quotes[indexPath.row].value
        config.secondaryText = quotes[indexPath.row].createdAt
        
        cell.contentConfiguration = config

        return cell
    }
}
