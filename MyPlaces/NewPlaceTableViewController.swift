//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 03.11.2025.
//

import UIKit

class NewPlaceTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
// MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
            view.endEditing(true)
        }
    }
    
    
    
}
// MARK: - Text field delegate

extension NewPlaceTableViewController: UITextFieldDelegate {
    //скрываем клавиатуру по нажатию "Done"
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
