//
//  Event+CoreDataProperties.swift
//  Event CheckIn
//
//  Created by Bari Chin on 15/09/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    
    @NSManaged public var eventName: String?
    @NSManaged public var eventPrice: String?
    @NSManaged public var eventStartTime: Date?
    @NSManaged public var eventEndTime: Date?
    @NSManaged public var eventCategory: String?

}
