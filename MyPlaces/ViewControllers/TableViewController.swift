//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 13.10.2025.
//

import UIKit
import RealmSwift

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //cв-во для ревлизации поиска
    private let searchController = UISearchController(searchResultsController: nil)
    
    //cв-во, с типом для Рилм БД
    private var places: Results<Place>!
    
    //массив для помищения отфильтрованых записей при поиске
    private var filteredPlaces: Results<Place>!
    
    //логическое св-во, говорящее пустая строка поиска или нет
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    //вспомогательное св-во которое возвращает true когда поисковый запрос активирован
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    //логическое св-во сортировки по возрастанию
    private var ascendingSorting = true
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reverseSortingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //настройка seatch controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        places = realm.objects(Place.self)

    }

    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if isFiltering {
             return filteredPlaces.count
         }
         return places.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CastomTableViewCell
         
       let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.raiting
        
        return cell
    }
    
    //MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        if editingStyle == .delete {
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
           
            //передача на экран редактирования с поискового вью
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            
            let newPlaceVC = segue.destination as! NewPlaceTableViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    @IBAction func undwindSegue(_ segue: UIStoryboardSegue) {
        //Передача данных между вью в ОБРАТНОМ (Соурс) направлении
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else {return}
        
        newPlaceVC.savePlace()

        tableView.reloadData()
        
    }

    @IBAction func sortSelectionPressed(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reverseSortingPressed(_ sender: Any) {
        //меняем значение на противоположное
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reverseSortingButton.image = UIImage(imageLiteralResourceName: "AZ")
        } else {
            reverseSortingButton.image = UIImage(imageLiteralResourceName: "ZA")
        }
        
        sorting()
    }
    
    //отдельный приватный метод сортировки что бы не повторяться
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
    
}
//расширение для реализации поиска
extension TableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@ OR type CONTAINS[c] %@", searchText, searchText, searchText)
        
        tableView.reloadData()
    }
    
}
