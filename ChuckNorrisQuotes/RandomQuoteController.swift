//
//  RandomQuoteController.swift
//  ChuckNorrisQuotes
//
//  Created by Евгения Шевякова on 17.09.2023.
//

import UIKit

class RandomQuoteController: UIViewController {
    
    @IBOutlet weak var showQuoteButton: UIButton!
    @IBOutlet weak var quoteLabel: UILabel!
    
    let quotesManager = QuotesManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pushShowQuoteAction(_ sender: Any) {
        showQuoteButton.isEnabled = false
        quotesManager.downloadQuote { textQuote, errorText in

            DispatchQueue.main.async {
                self.showQuoteButton.isEnabled = true
                
                if let errorText {
                    print(errorText)
                    self.quoteLabel.text = "Something went wrong. Push refresh again."
                } else if let textQuote {
                    self.quoteLabel.text = textQuote
                }
            }
        }
    }
}
