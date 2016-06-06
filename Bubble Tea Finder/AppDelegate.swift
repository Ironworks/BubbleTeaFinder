/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  lazy var  coreDataStack = CoreDataStack()
  
  
  func application(application: UIApplication,
    didFinishLaunchingWithOptions
    launchOptions: [NSObject: AnyObject]?) -> Bool {
      
      importJSONSeedDataIfNeeded()
      
      let navController = window!.rootViewController as! UINavigationController
      let viewController = navController.topViewController as! ViewController
      viewController.coreDataStack = coreDataStack
      
      return true
  }
  
  func applicationWillTerminate(application: UIApplication) {
    coreDataStack.saveContext()
  }
  
  func importJSONSeedDataIfNeeded() {
    
    let fetchRequest = NSFetchRequest(entityName: "Venue")
    var error: NSError? = nil
    
    let results =
    coreDataStack.context.countForFetchRequest(fetchRequest,
      error: &error)
    
    if (results == 0) {
      
      do {
        let results =
        try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Venue]
        
        for object in results {
          let team = object as Venue
          coreDataStack.context.deleteObject(team)
        }
        
        coreDataStack.saveContext()
        importJSONSeedData()
        
      } catch let error as NSError {
        print("Error fetching: \(error.localizedDescription)")
      }
    }
  }
  
  func importJSONSeedData() {
    let jsonURL = NSBundle.mainBundle().URLForResource("seed", withExtension: "json")
    let jsonData = NSData(contentsOfURL: jsonURL!)

    let venueEntity = NSEntityDescription.entityForName("Venue", inManagedObjectContext: coreDataStack.context)
    let locationEntity = NSEntityDescription.entityForName("Location", inManagedObjectContext: coreDataStack.context)
    let categoryEntity = NSEntityDescription.entityForName("Category", inManagedObjectContext: coreDataStack.context)
    let priceEntity = NSEntityDescription.entityForName("PriceInfo", inManagedObjectContext: coreDataStack.context)
    let statsEntity = NSEntityDescription.entityForName("Stats", inManagedObjectContext: coreDataStack.context)
    
    do {
      let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments) as! NSDictionary
      let jsonArray = jsonDict.valueForKeyPath("response.venues") as! NSArray
      
      for jsonDictionary in jsonArray {
        
        let venueName = jsonDictionary["name"] as? String
        let venuePhone = jsonDictionary.valueForKeyPath("contact.phone") as? String
        let specialCount = jsonDictionary.valueForKeyPath("specials.count") as? NSNumber
        
        let locationDict = jsonDictionary["location"] as! NSDictionary
        let priceDict = jsonDictionary["price"] as! NSDictionary
        let statsDict = jsonDictionary["stats"] as! NSDictionary
        
        let location = Location(entity: locationEntity!, insertIntoManagedObjectContext: coreDataStack.context)
        location.address = locationDict["address"] as? String
        location.city = locationDict["city"] as? String
        location.state = locationDict["state"] as? String
        location.zipcode = locationDict["postalCode"] as? String
        location.distance = locationDict["distance"] as? NSNumber
        
        let category = Category(entity: categoryEntity!, insertIntoManagedObjectContext: coreDataStack.context)
        
        let priceInfo = PriceInfo(entity: priceEntity!, insertIntoManagedObjectContext: coreDataStack.context)
        priceInfo.priceCategory = priceDict["currency"] as? String
        
        let stats = Stats(entity: statsEntity!, insertIntoManagedObjectContext: coreDataStack.context)
        stats.checkinsCount = statsDict["checkinsCount"] as? NSNumber
        stats.usersCount = statsDict["userCount"] as? NSNumber
        stats.tipCount = statsDict["tipCount"] as? NSNumber
        
        let venue = Venue(entity: venueEntity!, insertIntoManagedObjectContext: coreDataStack.context)
        venue.name = venueName
        venue.phone = venuePhone
        venue.specialCount = specialCount
        venue.location = location
        venue.category = category
        venue.priceInfo = priceInfo
        venue.stats = stats
      }
      
      coreDataStack.saveContext()
    } catch let error as NSError {
      print("Deserialization error: \(error.localizedDescription)")
    }
  }
  
}

