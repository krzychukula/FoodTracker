//
//  DetailViewController.swift
//  FoodTracker
//
//  Created by Krzysztof Kula on 20/06/15.
//  Copyright (c) 2015 Krzysztof Kula. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var usdaItem: USDAItem?

    @IBOutlet weak var textView: UITextView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if usdaItem != nil {
            textView.attributedText = createAttributedString(usdaItem!)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func eatItBarButtonItemPressed(sender: UIBarButtonItem) {
        
    }
    
    //MARK NSNotificationCenter
    func usdaItemDidComplete(nofication: NSNotification){
        println("USDAItem in DetailViewController")
        usdaItem = nofication.object as? USDAItem
        
        if self.isViewLoaded() && self.view.window != nil {
            textView.attributedText = createAttributedString(usdaItem!)
        }
    }
    
    func createAttributedString(usdaItem: USDAItem) -> NSAttributedString {
        var item = NSMutableAttributedString()
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        paragraphStyle.lineSpacing = 10.0
        
        var titleDictionary = [
            NSForegroundColorAttributeName :  UIColor.blackColor(),
            NSFontAttributeName : UIFont.boldSystemFontOfSize(22.0),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        
        let titleString = NSAttributedString(string: "\(usdaItem.name)\n", attributes: titleDictionary);
        
        item.appendAttributedString(titleString)
        
        return item
    }
}
