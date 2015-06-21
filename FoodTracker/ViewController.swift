//
//  ViewController.swift
//  FoodTracker
//
//  Created by Krzysztof Kula on 20/06/15.
//  Copyright (c) 2015 Krzysztof Kula. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,
        UITableViewDataSource, UITableViewDelegate,
        UISearchBarDelegate, UISearchControllerDelegate,
        UISearchResultsUpdating {
    
    var kAppId:String = ""
    var kAppKey:String = ""

    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    
    var suggestedSearchFoods:[String] = []
    var filteredSuggestedSearchFoods:[String] = []
    var favouritedUSDAItems:[USDAItem] = []
    var filteredFavouritedUSDAItems:[USDAItem] = []
    
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    var jsonResponse: NSDictionary!
    var apiSearchForFoods: [(name:String, idValue: String)] = []
    
    var dataController = DataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //MARK: how to hide api keys
        // http://stackoverflow.com/questions/30803244/how-to-hide-api-keys-in-github-for-ios-swift-projects
        //MARK: how to read plist
        //http://stackoverflow.com/questions/24045570/swift-read-plist
        if let path = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist") {
            println(path)
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                println(dict)
                // use swift dictionary as normal
                kAppId = dict["kAppId"] as! String
                kAppKey = dict["kApiKey"] as! String
            }
        }
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.searchController.searchBar.frame = CGRectMake(
            self.searchController.searchBar.frame.origin.x,
            self.searchController.searchBar.frame.origin.y,
            self.searchController.searchBar.frame.size.width, 44.0)
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.searchController.searchBar.scopeButtonTitles = scopeButtonTitles
        self.searchController.searchBar.delegate = self
        
        self.definesPresentationContext = true
        
        self.suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicken breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailVCSegue" {
            if sender != nil {
                var detailVC = segue.destinationViewController as! DetailViewController
                detailVC.usdaItem = sender as? USDAItem
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            if self.searchController.active {
                return self.filteredSuggestedSearchFoods.count
            }else{
                return self.suggestedSearchFoods.count
            }
        }else if selectedScopeButtonIndex == 1 {
            return self.apiSearchForFoods.count
        }else {
            if self.searchController.active {
                return self.filteredFavouritedUSDAItems.count
            }else{
                return self.favouritedUSDAItems.count
            }
            
        }
        
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        var foodName: String
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeButtonIndex == 0 {
            if self.searchController.active {
                foodName = self.filteredSuggestedSearchFoods[indexPath.row]
            }else{
                foodName = self.suggestedSearchFoods[indexPath.row]
            }
        }else if selectedScopeButtonIndex == 1 {
            foodName = self.apiSearchForFoods[indexPath.row].name
        }else {
            if self.searchController.active {
                foodName = self.filteredFavouritedUSDAItems[indexPath.row].name
            }else{
                foodName = self.favouritedUSDAItems[indexPath.row].name
            }
            
        }
        
        
        
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell;
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            var searchFoodNamed: String
            
            if self.searchController.active {
                searchFoodNamed = self.filteredSuggestedSearchFoods[indexPath.row]
            }else {
                searchFoodNamed = self.suggestedSearchFoods[indexPath.row]
            }
            self.searchController.searchBar.selectedScopeButtonIndex = 1;
            makeRequest(searchFoodNamed)
            
        }else if selectedScopeButtonIndex == 1 {
            //save food by id
            let idValue = apiSearchForFoods[indexPath.row].idValue
            self.dataController.saveUSDAValueItemForId(idValue, json: self.jsonResponse)
            
            self.performSegueWithIdentifier("toDetailVCSegue", sender: nil)
            
        }else if selectedScopeButtonIndex == 2 {
            
            if self.searchController.active {
                let usdaItem = filteredFavouritedUSDAItems[indexPath.row]
                self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
            }else{
                let usdaItem = favouritedUSDAItems[indexPath.row]
                self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
            }
            
        }
    }
    
    //MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = self.searchController.searchBar.text
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        self.tableView.reloadData()
    }
    
    func filterContentForSearch(searchText: String, scope: Int) {
        if scope == 0 {
            self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food:String) -> Bool in
                var foodMatch = food.rangeOfString(searchText)
                return foodMatch != nil
            })
        }else if scope == 2 {
            self.filteredFavouritedUSDAItems = self.favouritedUSDAItems.filter({ (item: USDAItem) -> Bool in
                var stringMatch = item.name.rangeOfString(searchText)
                return stringMatch != nil
            })
        }

    }
    
    //MARK: UISeachBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchController.searchBar.selectedScopeButtonIndex = 1
        makeRequest(searchBar.text)
    }
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        if selectedScope == 2 {
            self.requestFavouritedUSDAItems()
        }
        
        self.tableView.reloadData()
    }
    
    func makeRequest(searchText: String) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search/")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var params = [
            "appId" : kAppId,
            "appKey": kAppKey,
            "fields" : ["item_name", "brand_name", "keywords", "usda_fields"],
            "limit"  : "20",
            "query"  : searchText,
            "filters": ["exists":["usda_fields": true]]
        ]
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
            var conversionError:NSError?
            var jsonDictionary: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError)
            //println(jsonDictionary)
            
            if conversionError != nil {
                println(conversionError?.localizedDescription)
                let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error in \(errorString)")
            }else{
                if jsonDictionary != nil {
                    self.jsonResponse = jsonDictionary! as! NSDictionary
                    self.apiSearchForFoods = DataController.jsonAsUSDAIdAndNameSearchResults(jsonDictionary! as! NSDictionary)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                    
                }else{
                    let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Could not parse error in \(errorString)")
                }
            }
        })
        task.resume()
    }
    
    func makeGetRequest(searchText: String) {
        let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/\(searchText)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(kAppId)&appKey=\(kAppKey)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(stringData)
            println(response)
            println(error)
        })
        task.resume()
    }
    
    
    //MARK: setup core data
    func requestFavouritedUSDAItems(){
        let fetchRequest = NSFetchRequest(entityName: "USDAItem")
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        self.favouritedUSDAItems = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as! [USDAItem]
        
    }
}

