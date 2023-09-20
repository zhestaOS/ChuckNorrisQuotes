//
//  CategoriesController.swift
//  ChuckNorrisQuotes
//
//  Created by Евгения Шевякова on 20.09.2023.
//

import UIKit

class CategoriesController: UITableViewController {
    
    var categories = [String]()
    var categoriesDict = [String: [Quote]]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        QuotesManager.shared.fetchCategorizedQuotes { [weak self] dict in
            self?.categoriesDict = dict
            self?.categories = dict.keys.sorted(by: { $0 > $1 })
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var config = UIListContentConfiguration.cell()
        config.text = categories[indexPath.row]
        config.secondaryText = "Quotes: \(categoriesDict[categories[indexPath.row]]!.count)"
        
        cell.contentConfiguration = config

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quotes = categoriesDict[categories[indexPath.row]]
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AllQuotesController") as! AllQuotesController
        vc.title = categories[indexPath.row]
        vc.quotes = quotes
        navigationController?.pushViewController(vc, animated: true)
    }

}
