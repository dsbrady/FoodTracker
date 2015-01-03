//
//  DataController.swift
//  Foodtracker
//
//  Created by Scott Brady on 12/31/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let kUSDAItemCompleted = "USDAItemInstanceComplete"

class DataController {
	
	class func jsonAsUSDAIdAndNameSearchResults(json:NSDictionary) -> [(name:String, itemID:String)] {
		
		var usdaItemsSearchResults:[(name:String, itemID:String)] = []
		var searchResult: (name:String, itemID:String)
		
		if (json["hits"] != nil) {
			let results:[AnyObject] = json["hits"]! as [AnyObject]
			for itemDictionary in results {
				if (itemDictionary["_id"] != nil) {
					if (itemDictionary["fields"] != nil) {
						let fieldsDictionary = itemDictionary["fields"] as NSDictionary
						if (fieldsDictionary["item_name"] != nil) {
							let itemID:String = itemDictionary["_id"]! as String
							let name:String = fieldsDictionary["item_name"]! as String
							searchResult = (name:name, itemID:itemID)
							usdaItemsSearchResults += [searchResult]
						}
					}
				}
			}
		}
		
		return usdaItemsSearchResults
	}
	
	func saveUSDAItemForId(itemID:String, json:NSDictionary) {
		if (json["hits"] != nil) {
			let results:[AnyObject] = json["hits"]! as [AnyObject]
			
			for itemDictionary in results {
				if (itemDictionary["_id"] != nil && itemDictionary["_id"] as String == itemID) {
					let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
					var requestForUSDAItem = NSFetchRequest(entityName: "USDAItem")
					let itemDictionaryID = itemDictionary["_id"]! as String
					let predicate = NSPredicate(format: "itemID == %@", itemDictionaryID)
					
					requestForUSDAItem.predicate = predicate
					var error: NSError?
					var items = managedObjectContext?.executeFetchRequest(requestForUSDAItem, error: &error)

					if (items?.count != 0) {
						// The item is already saved
						println("The item was already saved")
						return
					}
					else {
						println("Let's save this to CoreData!")
						
						let entityDescription = NSEntityDescription.entityForName("USDAItem", inManagedObjectContext: managedObjectContext!)
						
						let usdaItem = USDAItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)

						usdaItem.itemID = itemDictionary["_id"]! as String
						usdaItem.dateAdded = NSDate()
						
						if (itemDictionary["fields"] != nil) {
							let fieldsDictionary = itemDictionary["fields"]! as NSDictionary
							if (fieldsDictionary["item_name"] != nil) {
								usdaItem.name = fieldsDictionary["item_name"]! as String
							}
							
							if (fieldsDictionary["usda_fields"] != nil) {
								let usdaFieldsDictionary = fieldsDictionary["usda_fields"]! as NSDictionary
								
								// Calcium
								if (usdaFieldsDictionary["CA"] != nil) {
									let calciumDictionary = usdaFieldsDictionary["CA"]! as NSDictionary
									if (calciumDictionary["value"] != nil) {
										let calciumValue: AnyObject = calciumDictionary["value"]!
										usdaItem.calcium = "\(calciumValue)"
									}
								}
								else {
									usdaItem.calcium = "0"
								}
								
								// Carbs
								if (usdaFieldsDictionary["CHOCDF"] != nil) {
									let carbDictionary = usdaFieldsDictionary["CHOCDF"]! as NSDictionary
									if (carbDictionary["value"] != nil) {
										let carbValue: AnyObject = carbDictionary["value"]!
										usdaItem.carbohydrate = "\(carbValue)"
									}
								}
								else {
									usdaItem.carbohydrate = "0"
								}
								
								// Fat
								if (usdaFieldsDictionary["FAT"] != nil) {
									let fatDictionary = usdaFieldsDictionary["FAT"]! as NSDictionary
									if (fatDictionary["value"] != nil) {
										let fatValue:AnyObject = fatDictionary["value"]!
										usdaItem.fatTotal = "\(fatValue)"
									}
								}
								else {
									usdaItem.fatTotal = "0"
								}

								// Cholesterol
								if (usdaFieldsDictionary["CHOLE"] != nil) {
									let cholesterolDictionary = usdaFieldsDictionary["CHOLE"]! as NSDictionary
									if (cholesterolDictionary["value"] != nil) {
										let cholesterolValue:AnyObject = cholesterolDictionary["value"]!
										usdaItem.cholesterol = "\(cholesterolValue)"
									}
								}
								else {
									usdaItem.cholesterol = "0"
								}
								
								// Protein
								if (usdaFieldsDictionary["PROCNT"] != nil) {
									let proteinDictionary = usdaFieldsDictionary["PROCNT"]! as NSDictionary
									if (proteinDictionary["value"] != nil) {
										let proteinValue:AnyObject = proteinDictionary["value"]!
										usdaItem.protein = "\(proteinValue)"
									}
								}
								else {
									usdaItem.protein = "0"
								}
								
								// Sugar
								if (usdaFieldsDictionary["SUGAR"] != nil) {
									let sugarDictionary = usdaFieldsDictionary["SUGAR"]! as NSDictionary
									if (sugarDictionary["value"] != nil) {
										let sugarValue:AnyObject = sugarDictionary["value"]!
										usdaItem.sugar = "\(sugarValue)"
									}
								}
								else {
									usdaItem.sugar = "0"
								}
								
								// Vitamin C
								if (usdaFieldsDictionary["VITC"] != nil) {
									let vitaminCDictionary = usdaFieldsDictionary["VITC"]! as NSDictionary
									if (vitaminCDictionary["value"] != nil) {
										let vitaminCValue:AnyObject = vitaminCDictionary["value"]!
										usdaItem.vitaminC = "\(vitaminCValue)"
									}
								}
								else {
									usdaItem.vitaminC = "0"
								}
								
								// Energy
								if (usdaFieldsDictionary["ENERC_KCAL"] != nil) {
									let energyDictionary = usdaFieldsDictionary["ENERC_KCAL"]! as NSDictionary
									if (energyDictionary["value"] != nil) {
										let energyValue:AnyObject = energyDictionary["value"]!
										usdaItem.energy = "\(energyValue)"
									}
								}
								else {
									usdaItem.energy = "0"
								}
								
								(UIApplication.sharedApplication().delegate as AppDelegate).saveContext()

								// Let the rest of the app know we're done
								NSNotificationCenter.defaultCenter().postNotificationName(kUSDAItemCompleted, object: usdaItem)
							}
						}
						
					}
				}
			}
		}
	}
}
