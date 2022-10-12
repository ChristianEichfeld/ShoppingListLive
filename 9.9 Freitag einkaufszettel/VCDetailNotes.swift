//
//  VCDetailNotiz.swift
//  9.9 Freitag einkaufszettel
//
//  Created by Christian Eichfeld on 12.09.22.
//

import UIKit
protocol CellProductDelegate {
    func editProduct (cell : CellProduct)
}

class CellProduct : UITableViewCell {
    
    var cellDelegate : CellProductDelegate?
    
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBAction func buttonEdit(_ sender: UIButton) {
        cellDelegate?.editProduct(cell: self)
    }
}

extension VCDetailNotes : CellProductDelegate {
                    func editProduct(cell: CellProduct) {
        
        if let indexPath = tableView.indexPath(for: cell){
                
            let list = self.detailList.list?.allObjects as! [Product]
            
            let product = list[indexPath.row]
            
                let alert = UIAlertController(
                    title: "Bearbeiten", message: "Bitte bearbeite deinen Text !", preferredStyle: .alert
                )
                
                alert.addTextField { field in
                    field.placeholder = product.name
                    field.returnKeyType = .continue
                }
                alert.addTextField { field in
                    field.placeholder = product.amount.description
                    field.returnKeyType = .continue
                }
                
                alert.addTextField { field in
                    field.placeholder = product.type
                    field.returnKeyType = .continue
                }
                
                alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel , handler: nil))
                alert.addAction(UIAlertAction(title: "Speichern", style: .default , handler: {_ in
                    
                    guard let fields = alert.textFields, fields.count == 3 else {
                        return
                    }
                    
                    let nameField = fields[0]
                    guard let titel = nameField.text
                    else {
                        print ("Invalid entries")
                        return
                    }
                    
                    let amountField = fields[1]
                    guard let amount = amountField.text
                    else {
                        print ("Invalid entries")
                        return
                    }
                    
                    let typeField = fields[2]
                    guard let type = typeField.text
                    else {
                        print ("Invalid entries")
                        return
                    }
                    
                    if titel != "" {
                        product.name = titel
                    }
                    
                    if amount != "" {
                        product.amount = Float(amount) ?? 0
                    }
                    
                    if type != "" {
                        product.type = type
                    }
                    
                   // let newProduct = Product (context: self.context)
                    //     newProduct.name = titel
                    //     newProduct.amount = amount
                     //    newProduct.check = false
                     //    newProduct.type = type
                      //   newProduct.shoppinglist = self.detailList
                    
                    do{
                        try self.context.save()
                    }
                    catch{
                        print ("data fehler")
                    }
                    
                    
                    self.tableView.reloadData()
                    
                }
                ))
                present (alert,animated: true)
            
 
        }
    }
}

class VCDetailNotes: UIViewController {
    
    var detailList : ShoppingList!
    
    var list1 : [Product]?
    
    var list2 : [Product]?
    
    var listIndex : Int!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addProduct(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(
            title: "Text", message: "Bitte Trage deinen Text ein !", preferredStyle: .alert
        )
        
        alert.addTextField { field in
            field.placeholder = "Text"
            field.returnKeyType = .continue
        }
        alert.addTextField { field in
            field.placeholder = "Menge"
            field.returnKeyType = .continue
        }
        
        alert.addTextField { field in
            field.placeholder = "Typ"
            field.returnKeyType = .continue
        }
        
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel , handler: nil))
        alert.addAction(UIAlertAction(title: "Hinzufügen", style: .default , handler: {_ in
            
            guard let fields = alert.textFields, fields.count == 3 else {
                return
            }
            
            let nameField = fields[0]
            let titel = nameField.text
            
            
            let amountField = fields[1]
             let amount = Float(amountField.text ?? "0")
            
            let typeField = fields[2]
             let type = typeField.text
            
            
            
            let newProduct = Product (context: self.context)
                 newProduct.name = titel
                 newProduct.amount = amount ?? 0
                 newProduct.check = false
                 newProduct.type = type
                 newProduct.shoppinglist = self.detailList
            
            do{
                try self.context.save()
            }
            catch{
                print ("data fehler")
            }
            
            self.tableView.reloadData()
            
        }
                                      
                                     ))
        present (alert,animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = detailList.headline
        tableView.dataSource = self
        tableView.delegate = self
    }
}





extension VCDetailNotes : UITableViewDataSource,UITableViewDelegate {
    
    func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return detailList.list?.count ?? 0
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
    return "Erledigt"
        }
        else {
            return ""
        }
    }
    
    func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let list = self.detailList.list?.allObjects as! [Product]
        
        let product = list[indexPath.row]
        
        let cell = tableView.dequeueReusableCell (withIdentifier: "ProductCell", for: indexPath) as! CellProduct
        
        if product.amount > 0 {
            cell.amount.text =  product.amount.description
        }
        else {
            cell.amount.text =  ""
        }
        
        cell.productLabel.text = product.name
        
        cell.typeLabel.text = product.type
        
        cell.cellDelegate = self
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let list = self.detailList.list?.allObjects as! [Product]

        list[indexPath.row].check = true
        
        NotificationCenter.default.post(name:NSNotification.Name.init("de.shoppingList.update"),object: (detailList,listIndex))
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let list = self.detailList.list?.allObjects as! [Product]
            
            let productToRemove = list[indexPath.row]
            context.delete(productToRemove)
            
            do{
                try self.context.save()
            }
            
            catch{
                print ("productToRemove fehler")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
}
