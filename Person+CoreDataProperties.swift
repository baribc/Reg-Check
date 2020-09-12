//
//  Person+CoreDataProperties.swift
//  Reg Check
//
//  Created by Bari Chin on 6/09/20.
//  Copyright © 2020 Bari Chin. All rights reserved.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var image: Data?
    @NSManaged public var lastName: String?
    @NSManaged public var membershipID: Int
    @NSManaged public var mobilePhone: String?
    @NSManaged public var phone: String?
    @NSManaged public var emailed: Date?
    @NSManaged public var emailedImg: Data?
    @NSManaged public var imported: Date?
    @NSManaged public var importedImg: Data?
    
    

}
