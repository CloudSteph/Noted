//
//  NoteMO+CoreDataProperties.swift
//  Noted
//
//  Created by Stephanie Liew on 8/24/22.
//
//

import Foundation
import CoreData


extension NoteMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteMO> {
        return NSFetchRequest<NoteMO>(entityName: "NoteMO")
    }

    @NSManaged public var date: Date?
    @NSManaged public var descr: String?
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?

}

extension NoteMO : Identifiable {

}
