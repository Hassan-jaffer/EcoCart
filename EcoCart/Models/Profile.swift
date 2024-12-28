//
//  Profile.swift
//  WeSide
//
//  Created by Yousif Isa Shamtoot on 10/04/2023.
//

import Foundation

import UIKit

class Profile {

    var name: String
    var email: String
    var image: String?

    init(name: String, email: String, image: String) {
        self.name = name
        self.email = email
        self.image = image
    }
    
    
    static func loadProfile(dictionary: [String: Any]) -> Profile? {
        
        guard
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String,
            let email = dictionary["email"] as? String
        else {
            print("[Profile.loadProfile] error parsing Poast, dumping dict", dictionary)
            return nil
        }
        let name = firstName + " " + lastName
        let image = dictionary["image"] as? String ?? "unknown.jpg"
        //print(name, image, email)
        
        return Profile(name: name, email: email, image: image)
    }
    
    static func saveProfile(uuid: String, profile: Profile) {
        
        Database.Users["users/" + uuid].setValue([
            "firstName": profile.name,
            "email": profile.email,
            "image": profile.image
        ], forKey: uuid)
    }
    
}

