//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 23.10.2025.
//

import UIKit

struct Place {
    
    var name: String
    var location: String?
    var type: String?
    var restoranImage: String?
    var image: UIImage?
    
   static let restaurantsNames = ["Балкан Гриль", "Бочка", "Вкусные истории", "Дастархан", "Индокитай", "Классик", "Шок", "Bonsai", "Burger Heroes", "Kitchen","Love&Life", "Morris Pub", "Sherlock Holmes", "Speak Easy", "X.O"]
       
    
  static func getPlaces() -> [Place] {
        var places = [Place]()
        
        for place in restaurantsNames {
            places.append(Place(name: place, location: "Уфа", type: "Ресторан", restoranImage: place, image: nil))
        }
        
        return places
    }
}
