//
//  Visitor+CoreDataProperties.swift
//  Reg Check
//
//  Created by Bari Chin on 6/09/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//
//

import Foundation
import CoreData


extension Visitor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Visitor> {
        return NSFetchRequest<Visitor>(entityName: "Visitor")
    }

    @NSManaged public var dateScanned: Date?
    @NSManaged public var membershipID: Int
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var email: String?
    @NSManaged public var mobilePhone: String?
    @NSManaged public var phone: String?
    @NSManaged public var event: String?
    

}
