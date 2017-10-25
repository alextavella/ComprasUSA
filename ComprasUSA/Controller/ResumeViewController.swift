//
//  ResumeViewController.swift
//  Wishlist
//
//  Created by Alex Tavella on 22/10/17.
//  Copyright © 2017 Alex Tavella. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ResumeViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var lbTotalDollar: UILabel!
    @IBOutlet weak var lbTotalReais: UILabel!
    
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resume()
    }
    
    
    // MARK: Methods
    
    func resume() {
        let products: [Product] = self.loadProducts()
        
        let totalDollar: Double = self.sum(values: products.map({ $0.value }))
        
        let quotation: Double = self.getQuotation()
        let iof: Double = self.getIOF()
        
        let calcReais: [Double] = self.calcReais(products: products, iof: iof, quotation: quotation)
        let totalReais: Double = self.sum(values: calcReais)
        
        self.lbTotalDollar.text = "\(totalDollar)"
        self.lbTotalReais.text = "\(totalReais)"
    }
    
    func loadProducts() -> [Product] {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func sum(values: [Double]) -> Double {
        return self.rounded(value: values.reduce(0, { $0 + $1 }))
    }
    
    func calcReais(products: [Product], iof: Double, quotation: Double) -> [Double] {
        return products.map { (product) -> Double in
            
            var result: Double = product.value
            
            if let state = product.state {
                let tax = 0.01 * state.tax
                result += product.value * tax
            }
            
            if product.creditcard {
                result += result * (0.01 * iof)
            }
            
            return result * quotation
        }
    }
    
    func getQuotation() -> Double {
        
        guard let quotation: String = UserDefaults.standard.string(forKey: Constants.KEYS.QUOTATION.rawValue) else { return 0 }
        
        return Double(quotation)!
    }
    
    func getIOF() -> Double {
        
        guard let iof: String = UserDefaults.standard.string(forKey: Constants.KEYS.IOF.rawValue) else { return 0 }
        
        return Double(iof)!
    }
    
    func rounded(value: Double) -> Double {
        let convertion: String = String(format: "%.2f", value)
        return Double(convertion)!
    }
}
