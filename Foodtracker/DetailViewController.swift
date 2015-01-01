//
//  DetailViewController.swift
//  Foodtracker
//
//  Created by Scott Brady on 12/30/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!
	
	var usdaItem:USDAItem?
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
println("here")
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	// MARK: NSNotificationCenter
	
	func usdaItemDidComplete(notification:NSNotification) {
		println("usdaItemDidComplete in DetailViewController")
		self.usdaItem = notification.object as? USDAItem
	}

	// MARK: IBActions

	@IBAction func eatItButtonPressed(sender: UIBarButtonItem) {
		
	}
	
}
