//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 23.10.2025.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    
 let restaurantsNames = ["Балкан Гриль", "Бочка", "Вкусные истории", "Дастархан", "Индокитай", "Классик", "Шок", "Bonsai", "Burger Heroes", "Kitchen","Love&Life", "Morris Pub", "Sherlock Holmes", "Speak Easy", "X.O"]
       
    
func savePlaces() {
        for place in restaurantsNames {
            
            let image = UIImage(named: place)
            guard let imageData = image?.pngData() else {return}
            
            let newPlace = Place()
            
            newPlace.name = place
            newPlace.location = "Москва"
            newPlace.type = "Ресторан"
            newPlace.imageData = imageData
            
            StorageManager.saveObject(newPlace)
            
        }
    }
       
}
