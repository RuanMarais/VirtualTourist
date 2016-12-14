//
//  CollectionPhoto+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/05.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import Foundation
import CoreData


public class CollectionPhoto: NSManagedObject {
    
    convenience init(name: String, locationStringBbox: String, urlString: String,  context: NSManagedObjectContext, data: NSData) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "CollectionPhoto", in: context) {
            self.init(entity: ent, insertInto: context)
            self.name = name
            self.locationStringBbox = locationStringBbox
            self.url = urlString
            self.imageData = data
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
