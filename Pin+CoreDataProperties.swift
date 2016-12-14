//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/13.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var pinPhotos: NSSet?

}

// MARK: Generated accessors for pinPhotos
extension Pin {

    @objc(addPinPhotosObject:)
    @NSManaged public func addToPinPhotos(_ value: CollectionPhoto)

    @objc(removePinPhotosObject:)
    @NSManaged public func removeFromPinPhotos(_ value: CollectionPhoto)

    @objc(addPinPhotos:)
    @NSManaged public func addToPinPhotos(_ values: NSSet)

    @objc(removePinPhotos:)
    @NSManaged public func removeFromPinPhotos(_ values: NSSet)

}
