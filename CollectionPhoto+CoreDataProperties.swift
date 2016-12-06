//
//  CollectionPhoto+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/05.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import Foundation
import CoreData


extension CollectionPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CollectionPhoto> {
        return NSFetchRequest<CollectionPhoto>(entityName: "CollectionPhoto");
    }

    @NSManaged public var locationStringBbox: String?
    @NSManaged public var url: String?
    @NSManaged public var name: String?
    @NSManaged public var ownerPin: Pin?

}
