//
//  TableViewController.swift
//  Wishlist
//
//  Created by Alex Tavella on 08/10/17.
//  Copyright © 2017 Alex Tavella. All rights reserved.
//

import UIKit
import CoreData

class ProductTableViewController: UITableViewController {

    // MARK: - Properties
    
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styles
        tableView.delegate = self
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.loadProducts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProductRegisterViewController {
            if self.tableView.indexPathForSelectedRow != nil {
                vc.product = fetchedResultController.object(at: self.tableView.indexPathForSelectedRow!)
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let count = fetchedResultController.fetchedObjects?.count else {return 0}
        if count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return 1
        }
        
        let rect = CGRect(x: 0,
                          y: 0,
                          width: self.tableView.bounds.size.width,
                          height: self.tableView.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: rect)
        
        noDataLabel.text = "Sua lista está vazia!"
        noDataLabel.textColor = UIColor.black
        noDataLabel.textAlignment = NSTextAlignment.center
        self.tableView.backgroundView = noDataLabel
        self.tableView.separatorStyle = .none
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = fetchedResultController.fetchedObjects?.count else {return 0}
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let product = fetchedResultController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "productCell",
            for: indexPath) as! ProductTableViewCell
        
        let via: String = product.creditcard ? "💳" : "💵"
        
        cell.lbName.text = product.name
        cell.lbValue.text = "$\(product.value) \(via)"
        cell.lbState.text = product.state?.name
        
        if let photo = product.photo as? UIImage {
            cell.ivPhoto.image = photo
        } else {
            cell.ivPhoto.image = UIImage(named: "photo.png")
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = fetchedResultController.object(at: indexPath)
            context.delete(product)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - Methods
    
    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
}


// MARK: - NSFetchedResultsControllerDelegate
extension ProductTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
