//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 13.10.2025.
//

import UIKit

class TableViewController: UITableViewController {

    let restaurantsNames = ["Балкан Гриль", "Бочка", "Вкусные истории", "Дастархан", "Индокитай", "Классик", "Шок", "Bonsai", "Burger Heroes", "Kitchen","Love&Life", "Morris Pub", "Sherlock Holmes", "Speak Easy", "X.O"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantsNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = restaurantsNames[indexPath.row]
        cell.imageView?.image = UIImage(named: restaurantsNames[indexPath.row])
        return cell
    }


    

}
