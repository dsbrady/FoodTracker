//
//  ViewController.swift
//  Foodtracker
//
//  Created by Scott Brady on 12/30/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

	@IBOutlet weak var tableView: UITableView!

	let kApiURL = "https://api.nutritionix.com/v1_1/search/"
	let kAppId = "5c20781c"
	let kAppKey = "b5349210b1a10e098939cbad42bbcb3c"
	
	var searchController: UISearchController!
	
	var suggestedSearchFoods:[String] = []
	var filteredSuggestedSearchFoods:[String] = []
	
	var favoriteUSDAItems:[USDAItem] = []
	var filteredFavoriteUSDAItems:[USDAItem] = []

	var apiSearchForFoods:[(name:String, itemID:String)] = []
	
	var scopeButtonTitles = ["Recommended","Search Results","Saved"]
	
	var jsonResponse:NSDictionary!
	
	var dataController = DataController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		self.searchController = UISearchController(searchResultsController: nil)
		self.searchController.searchResultsUpdater = self
		self.searchController.dimsBackgroundDuringPresentation = false
		self.searchController.hidesNavigationBarDuringPresentation = false
		
		self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
		self.tableView.tableHeaderView = self.searchController.searchBar
		
		self.searchController.searchBar.scopeButtonTitles = self.scopeButtonTitles
		self.searchController.searchBar.delegate = self
		
		self.definesPresentationContext = true
		
		self.suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicen breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "toDetailVCSegue") {
			if (sender != nil) {
				var detailVC = segue.destinationViewController as DetailViewController
				detailVC.usdaItem = sender as? USDAItem
			}
		}
	}
	// MARK: UITableViewDataSource
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
		var foodName:String
		let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex

		if (selectedScopeButtonIndex == 0) {
			if (self.searchController.active) {
				foodName = self.filteredSuggestedSearchFoods[indexPath.row]
			}
			else {
				foodName = self.suggestedSearchFoods[indexPath.row]
			}
		}
		else if (selectedScopeButtonIndex == 1) {
			foodName = self.apiSearchForFoods[indexPath.row].name
		}
		else {
			if (self.searchController.active) {
				foodName = self.filteredFavoriteUSDAItems[indexPath.row].name
			}
			else {
				foodName = self.favoriteUSDAItems[indexPath.row].name
			}
		}
		
		cell.textLabel?.text = foodName
		cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		
		return cell
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
		
		if (selectedScopeButtonIndex == 0) {
			if (self.searchController.active) {
				return self.filteredSuggestedSearchFoods.count
			}
			else {
				return self.suggestedSearchFoods.count
			}
		}
		else if (selectedScopeButtonIndex == 1) {
			return self.apiSearchForFoods.count
		}
		else {
			if (self.searchController.active) {
				return self.filteredFavoriteUSDAItems.count
			}
			else {
				return self.favoriteUSDAItems.count
			}
		}
	}
	
	// MARK: UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
		if (selectedScopeButtonIndex == 0) {
			var searchFoodName:String
			if (self.searchController.active) {
				searchFoodName = self.filteredSuggestedSearchFoods[indexPath.row]
			}
			else {
				searchFoodName = self.suggestedSearchFoods[indexPath.row]
			}
			self.searchController.searchBar.selectedScopeButtonIndex = 1
			makeRequest(searchFoodName)
		}
		else if (selectedScopeButtonIndex == 1) {
			let itemID = self.apiSearchForFoods[indexPath.row].itemID
			self.performSegueWithIdentifier("toDetailVCSegue", sender: nil)
			self.dataController.saveUSDAItemForId(itemID, json: self.jsonResponse)
		}
		else if (selectedScopeButtonIndex == 2) {
			if (self.searchController.active) {
				let usdaItem = filteredFavoriteUSDAItems[indexPath.row]
				self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
			}
			else {
				let usdaItem = favoriteUSDAItems[indexPath.row]
				self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
			}
		}
	}
	
	// MARK: UISSearchBarDelegate
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		self.searchController.searchBar.selectedScopeButtonIndex = 1
		makeRequest(searchBar.text)
	}
	
	func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		if (selectedScope == 2) {
			requestFavoriteUSDAItems()
		}
		
		self.tableView.reloadData()
	}
	
	// MARK: UISearchResultsUpdating
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		let searchString = self.searchController.searchBar.text
		let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
		self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
		self.tableView.reloadData()
	}
	
	// MARK: Helper functions
	
	func filterContentForSearch(searchText:String, scope: Int) {
		if (scope == 0) {
			self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food:String) -> Bool in
				var foodMatch = food.rangeOfString(searchText)
				
				return foodMatch != nil
			})
		}
		else if (scope == 2) {
			self.filteredFavoriteUSDAItems = self.favoriteUSDAItems.filter({ (item:USDAItem) -> Bool in
				var stringMatch = item.name.rangeOfString(searchText)
				return stringMatch != nil
			})
		}
	}
	
	func makeRequest (searchString:String) {
		
		// How to make a GET request
//		let url = NSURL(string: "\(self.kApiURL)\(searchString)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(self.kAppId)&appKey=\(self.kAppKey)")
//		let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
//			var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
//			println(stringData)
//			println(response)
//		}
//		task.resume()
		
		// How to make a POST request
		var request = NSMutableURLRequest(URL: NSURL(string: self.kApiURL)!)
		let session = NSURLSession.sharedSession()
		request.HTTPMethod = "POST"
		var params = [
			"appId": self.kAppId,
			"appKey": self.kAppKey,
			"fields": ["item_name", "brand_name", "keywords", "usda_fields"],
			"limit": "50",
			"query": searchString,
			"filters": ["exists":["usda_fields": true]]
		]
		var error: NSError?
		request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
			var conversionError: NSError?
			var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
//			println(jsonDictionary)
			
			if (conversionError != nil) {
				println(conversionError!.localizedDescription)
				let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
				println("Error in parsing: \(errorString)")
			}
			else {
				if (jsonDictionary != nil) {
					self.jsonResponse = jsonDictionary!
					self.apiSearchForFoods = DataController.jsonAsUSDAIdAndNameSearchResults(jsonDictionary!)
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						self.tableView.reloadData()
					})
				}
				else {
					let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
					println("Error Could Not Parse JSON \(errorString)")
				}
			}

		})
		task.resume()
	}
	
	// MARK: Setup CoreData
	
	func requestFavoriteUSDAItems() {
		let fetchRequest = NSFetchRequest(entityName: "USDAItem")
		let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
		let managedObjectContext = appDelegate.managedObjectContext
		self.favoriteUSDAItems = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as [USDAItem]
	}

	// MARK: NSNotificationCenter

	func usdaItemDidComplete(notification:NSNotification) {
		println("usdaItemDidComplete in ViewController")
		requestFavoriteUSDAItems()
		let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
		
		if (selectedScopeButtonIndex == 2) {
			self.tableView.reloadData()
		}
	}
}

