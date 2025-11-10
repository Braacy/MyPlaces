//
//  Storage manager.swift
//  MyPlaces
//
//  Created by Владислав Близнюк on 10.11.2025.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
}
