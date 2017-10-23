//
//  StateViewController.swift
//  Wishlist
//
//  Created by Alex Tavella on 15/10/17.
//  Copyright © 2017 Alex Tavella. All rights reserved.
//

import UIKit
import CoreData

enum CommandType {
    case add
    case edit
}

class StateRegisterViewController: UIViewController {
    
    // MARK: - Outlet
    
    @IBOutlet weak var tfQuotation: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var dataSource: [State] = []
    var product: Product!
    var lastSelectedRow: IndexPath?
    
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tfQuotation.delegate = self
        self.tfIOF.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tfQuotation.text = UserDefaults.standard.string(forKey: Constants.KEYS.QUOTATION.rawValue)
        self.tfIOF.text = UserDefaults.standard.string(forKey: Constants.KEYS.IOF.rawValue)
        
        self.loadStates()
        self.tableView.allowsSelection = product != nil
    }
    
    
    // MARK: - Methods
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            self.dataSource = try context.fetch(fetchRequest)
            self.tableView.reloadData()
            showEmptyState(self.tableView)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func showEmptyState(_ tableView: UITableView) -> Void {
        
        let count: Int = dataSource.count
        if count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return
        }
        
        let rect = CGRect(x: 0,
                          y: 0,
                          width: self.tableView.bounds.size.width,
                          height: self.tableView.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: rect)
        
        noDataLabel.text = "Sua lista de estados está vazia!"
        noDataLabel.textColor = UIColor.black
        noDataLabel.textAlignment = NSTextAlignment.center
        self.tableView.backgroundView = noDataLabel
        self.tableView.separatorStyle = .none
    }
    
    func showAlert(type: CommandType, state: State?) {
        let title = "Adicionar"
        
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do estado"
            if let name = state?.name {
                textField.text = name
            }
        }
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Imposto"
            textField.keyboardType = .numberPad
            if let tax = state?.tax {
                textField.text = "\(tax)"
            }
        }
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state = state ?? State(context: self.context)
            
            let nameField = alert.textFields?.first?.text
            let iofField = alert.textFields?.last?.text
            
            state.name = nameField!
            state.tax = Double(iofField!)!
            
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                print(error.localizedDescription)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func add(_ sender: Any) {
        showAlert(type: .add, state: nil)
    }
}


// MARK: - UITableViewDelegate
extension StateRegisterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = dataSource[indexPath.row]
        
        if let lastSelectedRow = lastSelectedRow {
            let lastSelectedCell = tableView.cellForRow(at: lastSelectedRow)!
            lastSelectedCell.accessoryType = .none
        }
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            product.state = state
        } else {
            cell.accessoryType = .none
            product.state = nil
        }
        
        lastSelectedRow = indexPath
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.dataSource[indexPath.row]
            self.context.delete(state)
            try! self.context.save()
            self.dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [deleteAction]
    }
}

// MARK: - UITableViewDelegate
extension StateRegisterViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stateCell", for: indexPath)
        let state = dataSource[indexPath.row]
        cell.textLabel?.text = state.name
        cell.detailTextLabel?.text = "\(state.tax)"
        cell.accessoryType = .none
        if product != nil {
            if let selectedState = product.state, selectedState == state {
                cell.accessoryType = .checkmark
                lastSelectedRow = indexPath
            }
        }
        return cell
    }
}


extension StateRegisterViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == tfQuotation {
            UserDefaults.standard.set(textField.text, forKey: Constants.KEYS.QUOTATION.rawValue)
        } else if textField == tfIOF {
            UserDefaults.standard.set(textField.text, forKey: Constants.KEYS.IOF.rawValue)
        }
    }
}

