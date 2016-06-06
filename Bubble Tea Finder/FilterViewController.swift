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

class FilterViewController: UITableViewController {
  
  @IBOutlet weak var firstPriceCategoryLabel: UILabel!
  @IBOutlet weak var secondPriceCategoryLabel: UILabel!
  @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
  @IBOutlet weak var numDealsLabel: UILabel!
  
  //Price section
  @IBOutlet weak var cheapVenueCell: UITableViewCell!
  @IBOutlet weak var moderateVenueCell: UITableViewCell!
  @IBOutlet weak var expensiveVenueCell: UITableViewCell!
  
  //Most popular section
  @IBOutlet weak var offeringDealCell: UITableViewCell!
  @IBOutlet weak var walkingDistanceCell: UITableViewCell!
  @IBOutlet weak var userTipsCell: UITableViewCell!
  
  //Sort section
  @IBOutlet weak var nameAZSortCell: UITableViewCell!
  @IBOutlet weak var nameZASortCell: UITableViewCell!
  @IBOutlet weak var distanceSortCell: UITableViewCell!
  @IBOutlet weak var priceSortCell: UITableViewCell!
    
    var coreDataStack: CoreDataStack!
    
    lazy var cheapVenuePredicate: NSPredicate = {
        var predicate = NSPredicate(format: "priceInfo.priceCategory == %@", "$")
        return predicate
    }()
    
    lazy var moderateVenuePredicate: NSPredicate = {
        var predicate = NSPredicate(format: "priceInfo.priceCategory == %@", "$$")
        return predicate
    }()
    
    
    
    func populateCheapVenueCountLabel() {
        
        //$ fetch request
        let fetchRequest = NSFetchRequest(entityName: "Venue")
        fetchRequest.resultType = .CountResultType
        fetchRequest.predicate = cheapVenuePredicate
        
        do {
            let results  = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [NSNumber]
            
            let count = results.first!.integerValue
            firstPriceCategoryLabel.text = "\(count) bubble tea places"
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func populateModerateVenueCountLabel() {
        //$$ fetch
        let fetchRequest = NSFetchRequest(entityName: "Venue")
        fetchRequest.resultType = .CountResultType
        fetchRequest.predicate = moderateVenuePredicate
        
        do {
            let results  = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [NSNumber]
            let count = results.first!.integerValue
            secondPriceCategoryLabel.text = "\(count) bubble tea places"
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
  //MARK - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        populateCheapVenueCountLabel()
        populateModerateVenueCountLabel()
    }

  //MARK - UITableViewDelegate methods
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
  
  // MARK - UIButton target action
  
  @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
    
    dismissViewControllerAnimated(true, completion:nil)
  }
}
