//
//  USDAItem.swift
//  Foodtracker
//
//  Created by Scott Brady on 12/31/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

import Foundation
import CoreData

@objc(USDAItem)

class USDAItem: NSManagedObject {

    @NSManaged var calcium: String
    @NSManaged var carbohydrate: String
    @NSManaged var cholesterol: String
    @NSManaged var dateAdded: NSDate
    @NSManaged var energy: String
    @NSManaged var fatTotal: String
    @NSManaged var itemID: String
    @NSManaged var name: String
    @NSManaged var protein: String
    @NSManaged var sugar: String
    @NSManaged var vitaminC: String

}
