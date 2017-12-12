//
//  QuoteViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/6/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit

class QuoteViewController: UIViewController {
    @IBOutlet weak var quote: UILabel!
    @IBOutlet weak var author: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateQuotes()
    }
    
    private func setupUI() {
        if let quoteData = RandomQuoteGenerator.generate() {
            author.text = quoteData.author
            quote.text = quoteData.quote
        }
        
        author.alpha = 0.0
        quote.alpha = 0.0

    }
    
    private func animateQuotes() {
        UIView.animate(withDuration: 0.8, animations: {
            self.quote.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.8, animations: {
                self.author.alpha = 1.0
            })
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        
    }
    
    @IBAction func login(_ sender: Any) {
        
    }
}
