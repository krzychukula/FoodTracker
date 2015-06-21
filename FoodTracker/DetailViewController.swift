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
        
        
        
        var leftParagraphStyle = NSMutableParagraphStyle()
        leftParagraphStyle.alignment = NSTextAlignment.Left
        leftParagraphStyle.lineSpacing = 20.0
        
        var firstWordDictionary = [
            NSForegroundColorAttributeName :  UIColor.blackColor(),
            NSFontAttributeName : UIFont.boldSystemFontOfSize(18.0),
            NSParagraphStyleAttributeName: leftParagraphStyle
        ]
        var style1Dictionary = [
            NSForegroundColorAttributeName :  UIColor.darkGrayColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(18.0),
            NSParagraphStyleAttributeName: leftParagraphStyle
        ]
        var style2Dictionary = [
            NSForegroundColorAttributeName :  UIColor.lightGrayColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(18.0),
            NSParagraphStyleAttributeName: leftParagraphStyle
        ]
        
        
        let calciumTitleString = NSAttributedString(string: "Calcium ", attributes: firstWordDictionary);
        let calciumBodyString = NSAttributedString(string: "\(usdaItem.calcium)% \n", attributes: style1Dictionary)
        item.appendAttributedString(calciumTitleString)
        item.appendAttributedString(calciumBodyString)
        
        
        let carbohydrateTitleString = NSAttributedString(string: "Carbohydrate ", attributes: firstWordDictionary);
        let carbohydrateBodyString = NSAttributedString(string: "\(usdaItem.carbohydrate)% \n", attributes: style2Dictionary)
        item.appendAttributedString(carbohydrateTitleString)
        item.appendAttributedString(carbohydrateBodyString)
        
        
        let cholesterolTitleString = NSAttributedString(string: "Cholesterol ", attributes: firstWordDictionary);
        let cholesterolBodyString = NSAttributedString(string: "\(usdaItem.cholesterol)% \n", attributes: style1Dictionary)
        item.appendAttributedString(cholesterolTitleString)
        item.appendAttributedString(cholesterolBodyString)
        
        
        // Energy
        let energyTitleString = NSAttributedString(string: "Energy ", attributes: firstWordDictionary)
        let energyBodyString = NSAttributedString(string: "\(usdaItem.energy)% \n", attributes: style2Dictionary)
        item.appendAttributedString(energyTitleString)
        item.appendAttributedString(energyBodyString)
        
        // Fat Total
        let fatTotalTitleString = NSAttributedString(string: "FatTotal ", attributes: firstWordDictionary)
        let fatTotalBodyString = NSAttributedString(string: "\(usdaItem.fatTotal)% \n", attributes: style1Dictionary)
        item.appendAttributedString(fatTotalTitleString)
        item.appendAttributedString(fatTotalBodyString)
        
        // Protein
        let proteinTitleString = NSAttributedString(string: "Protein ", attributes: firstWordDictionary)
        let proteinBodyString = NSAttributedString(string: "\(usdaItem.protein)% \n", attributes: style2Dictionary)
        item.appendAttributedString(proteinTitleString)
        item.appendAttributedString(proteinBodyString)
        
        
        // Sugar
        let sugarTitleString = NSAttributedString(string: "Sugar ", attributes: firstWordDictionary)
        let sugarBodyString = NSAttributedString(string: "\(usdaItem.sugar)% \n", attributes: style1Dictionary)
        item.appendAttributedString(sugarTitleString)
        item.appendAttributedString(sugarBodyString)
        
        // Vitamin C
        let vitaminCTitleString = NSAttributedString(string: "Vitamin C ", attributes: firstWordDictionary)
        let vitaminCBodyString = NSAttributedString(string: "\(usdaItem.vitaminC)% \n", attributes: style2Dictionary)
        item.appendAttributedString(vitaminCTitleString)
        item.appendAttributedString(vitaminCBodyString)
        
        return item
    }
}
