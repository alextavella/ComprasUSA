//
//  CreateProductViewController.swift
//  Wishlist
//
//  Created by Alex Tavella on 08/10/17.
//  Copyright © 2017 Alex Tavella. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ProductRegisterViewController: UIViewController {
    
    // MARK: - Outlet
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfValue: UITextField!
    @IBOutlet weak var swCreditcard: UISwitch!
    @IBOutlet weak var btCreate: UIButton!
    
    // MARK: - Properties
    
    var product: Product!
    var smallImage: UIImage!
    
    var pickerView: UIPickerView!
    var states: [State] = []
    var statesName: [String]?
    
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editMode = self.product != nil
        self.title = editMode ? "Atualizar Produto" : "Cadastrar Produto"
        
        let buttonTitle: String = editMode ? "Atualizar" : "Cadastrar"
        self.btCreate.setTitle(buttonTitle.uppercased(), for: .normal)
    
        self.buildView()
        self.statesName = self.fetchStates()
            .map({($0).name!})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchProduct()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StateRegisterViewController {
            if product == nil {
                product = Product(context: context)
            }
            vc.product = product
        }
    }
    
    
    // MARK: - Events
    
    @IBAction func createOrUpdate(_ sender: UIButton) {
        if valid() {
        
            if product == nil {
                product = Product(context: context)
            }

            product.name = tfName.text!
            product.value = Double(tfValue.text!)!
            product.creditcard = swCreditcard.isOn

            if smallImage != nil {
                product.photo = smallImage
            }

            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
            
            close()
        }
    }
    
    @objc func addPhoto(_ sender: Any) {
        showSelectPhotos()
    }
    
    
    // MARK: - Methods
    
    func buildView() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addPhoto(_:)))
        ivPhoto.isUserInteractionEnabled = true
        ivPhoto.gestureRecognizers = [tapGesture]
        
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfState.inputView = pickerView
        tfState.inputAccessoryView = toolbar
    }
    
    func showSelectPhotos() {
        let alert = UIAlertController(title: "Selecionar imagem", message: "De onde você quer escolher o poster?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func valid() -> Bool {
        var validateMessage: String = ""
        
        if tfName.text!.count == 0 {
            validateMessage = "Nome é obrigatório"
        }
        else if tfState.text!.count == 0 {
            validateMessage = "Estado é obrigatório"
        }
        else if tfValue.text!.count == 0 {
            validateMessage = "Valor é obrigatório"
        }
        
        if validateMessage != "" {
            let alert = UIAlertController(title: "Validação", message: validateMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    func fetchProduct() {
        if product != nil {
            
            tfName.text = product.name
            tfValue.text = "\(product.value)"
            swCreditcard.isOn = product.creditcard
            
            if let state = product.state {
                tfState.text = state.name
            }
            
            if let image = product.photo as? UIImage {
                ivPhoto.image = image
            }
            
            if let state = product.state {
                tfState.text = state.name
            }
        }
    }
    
    func fetchStates() -> [State] {
        
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            states = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        return states
    }
    
    func close() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: PickerView
    @objc func cancel() {
        tfState.resignFirstResponder()
    }
    
    @objc func done() {
        if states.count > 0 {
            
            let rowIndex: Int = pickerView.selectedRow(inComponent: 0)
            let state: State = states[rowIndex]
            tfState.text = state.name
            
            if product == nil {
                product = Product(context: context)
            }
            product.state = state
        }
        cancel()
    }
}


// MARK: - UIImagePickerControllerDelegate
extension ProductRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {

        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))

        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        ivPhoto.image = smallImage

        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIPickerViewDelegate
extension ProductRegisterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statesName?[row] ?? ""
    }
}

// MARK: - UIPickerViewDataSource
extension ProductRegisterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statesName?.count ?? 0
    }
}

