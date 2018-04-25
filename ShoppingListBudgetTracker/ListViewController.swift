/*
Copyright (c) 2014, Andrew Schools <andrewschools@me.com>

Permission is hereby granted, free of charge, to any
person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the
Software without restriction, including without
limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the
following conditions:
The above copyright notice and this permission notice
shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var lists = [List]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.lists = self.getLists()!
    }
    
    @IBAction func addName(sender: AnyObject) {
        self.showAddName()
    }
    
    // show add name alert box
    func showAddName() {
        var alert = UIAlertController(
            title: "Add a new list",
            message: "Name of list:",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        // save button
        let saveAction = UIAlertAction(
            title: "Save",
            style: UIAlertActionStyle.Default, {(action: UIAlertAction!) -> Void in
                // save button clicked so get name, show budget alert box
                let textField = alert.textFields![0] as UITextField
                self.showAddBudget(textField.text)
            }
        )
        
        // cancel button
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Default, {(action: UIAlertAction!) -> Void in
        })
        
        // textbox configuration
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        // add buttons to alert box
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        // show alert box
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // show add budget alert box
    func showAddBudget(name:String) {
        var alert = UIAlertController(
            title: "Add budget",
            message: "Add a budget for " + name + ":",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        // save button
        let saveAction = UIAlertAction(
            title: "Save",
            style: UIAlertActionStyle.Default, {(action: UIAlertAction!) -> Void in
                // save button clicked, save list
                let textField = alert.textFields![0] as UITextField
                let budget = NSString(string: textField.text)
                
                self.addList(name, budget: budget.doubleValue)
                self.tableView.reloadData()
            }
        )
        
        // cancel button
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Default, {(action: UIAlertAction!) -> Void in}
        )
        
        // text box configuration
        alert.addTextFieldWithConfigurationHandler {(textField: UITextField!) -> Void in
            // they are entering a price so show the decimal keyboard
            textField.keyboardType = UIKeyboardType.DecimalPad
        }
        
        // add buttons to alert box
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        // show alert box
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func addList(name: String, budget: Double) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("List", inManagedObjectContext: managedContext)
        
        // create a new list object
        let list = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as List
        list.name = name
        list.budget = budget
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        // update our lists array with our new list
        self.lists.append(list)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "ListViewCell"
        let item = self.lists[indexPath.row] as List
        
        var cell: ListViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier) as? ListViewCell
        
        if cell? == nil {
            cell = ListViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier:identifier)
        }
        
        let budget: Double? = item.valueForKey("budget") as Double?
        
        cell!.name.text = item.valueForKey("name") as String?
        cell!.budget.text = String(format:"%.2f", budget!)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // user clicked on a list so we should show the items in the list
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("NavItemViewController") as UINavigationController
        let item = self.lists[indexPath.row] as List
        
        // pass selected list to items controller
        let controller = vc.topViewController as ItemViewController
        controller.setList(item)
        
        // show items controller
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // delete list
        var error: NSErrorPointer = NSErrorPointer()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        managedContext.deleteObject(self.lists[indexPath.row])
        managedContext.save(error)
        
        self.reloadTable()
    }
    
    func getLists() -> [List]? {
        // get list from Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"List")
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [List]?
        
        return fetchedResults
    }
    
    func reloadTable() {
        self.lists = self.getLists()!
        self.tableView.reloadData()
    }
    
}

