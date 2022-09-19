//
//  NoteMO+CoreDataProperties.swift
//  Noted
//
//  Created by Stephanie Liew on 8/26/22.
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
    @NSManaged public var secret: String?
    @NSManaged public var secretHidden: Bool

}

extension NoteMO : Identifiable {

}
