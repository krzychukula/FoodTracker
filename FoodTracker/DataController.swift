//
//  DataController.swift
//  FoodTracker
//
//  Created by Krzysztof Kula on 21/06/15.
//  Copyright (c) 2015 Krzysztof Kula. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataController {
    class func jsonAsUSDAIdAndNameSearchResults(json:NSDictionary) -> [(name: String, idValue: String)] {
        var usdaItemsSearchResults:[(name:String, idValue: String)] = []
        var searchResult: (name: String, idValue:String)
        
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]! as! [AnyObject]
            for itemDictionary in results {
                if itemDictionary["_id"] != nil {
                    if itemDictionary["fields"] != nil {
                        let fieldsDictionary = itemDictionary["fields"] as! NSDictionary
                        
                        if fieldsDictionary["item_name"] != nil {
                            let idValue:String = itemDictionary["_id"]! as! String
                            let name:String = fieldsDictionary["item_name"]! as! String
                            searchResult = (name: name, idValue: idValue)
                            usdaItemsSearchResults += [searchResult]
                        }
                    }
                }
            }
        }
        return usdaItemsSearchResults
    }
    
    func saveUSDAValueItemForId(idValue: String, json: NSDictionary){
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]! as! [AnyObject]
            
            for itemDictionary in results {
                if itemDictionary["_id"] != nil && itemDictionary["_id"] as! String == idValue {
                    
                    //check if it was saved
                    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                    var requestForUSDAItem = NSFetchRequest(entityName: "USDAItem")
                    let predicate = NSPredicate(format: "idValue == %@", idValue)
                    requestForUSDAItem.predicate = predicate
                    var error: NSError?
                    var items = managedObjectContext?.executeFetchRequest(requestForUSDAItem, error: &error)
                    
                    if items?.count != 0 {
                        //item is already saved
                        return
                    }else {
                        println("Lets save \(idValue) to CoreData")
                        
                        let entityDescription = NSEntityDescription.entityForName("USDAItem", inManagedObjectContext: managedObjectContext!)
                        let usdaItem = USDAItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                        usdaItem.idValue = idValue
                        usdaItem.dateAdded = NSDate()
                        if itemDictionary["fields"] != nil {
                            //FIELDS
                            
                            //name
                            let fieldsDictionary = itemDictionary["fields"]! as! NSDictionary
                            if fieldsDictionary["item_name"] != nil {
                                usdaItem.name = fieldsDictionary["item_name"]! as! String
                            }
                            
                           
                            if let usdaFieldsDictionary = fieldsDictionary["usda_fields"] as? NSDictionary {
                                
                                //calcium
                                if let calciumDictionary = usdaFieldsDictionary["CA"] as? NSDictionary {
                                    let calciumValue: AnyObject = calciumDictionary["value"]!
                                    usdaItem.calcium = "\(calciumValue)"
                                }else{
                                    usdaItem.calcium = "0"
                                }
                                
                                //carophydrate
                                if let carbohydrateDictionary = usdaFieldsDictionary["CHOCDF"] as? NSDictionary {
                                    
                                    usdaItem.carbohydrate = carbohydrateDictionary["value"]! as! String
                                }else{
                                    usdaItem.carbohydrate = "0"
                                }
                                
                                //fat
                                if let fatDictionary = usdaFieldsDictionary["FAT"] as? NSDictionary {
                                    
                                    usdaItem.fatTotal = fatDictionary["value"]! as! String
                                }else{
                                    usdaItem.fatTotal = "0"
                                }
                                
                                //cholesterol
                                if let cholesterolDictionary = usdaFieldsDictionary["CHOLE"] as? NSDictionary {
                                    
                                    usdaItem.cholesterol = cholesterolDictionary["value"]! as! String
                                }else{
                                    usdaItem.cholesterol = "0"
                                }
                                
                                //protein
                                if let proteinDictionary = usdaFieldsDictionary["PROCNT"] as? NSDictionary {
                                    
                                    usdaItem.protein = proteinDictionary["value"]! as! String
                                }else{
                                    usdaItem.protein = "0"
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
}