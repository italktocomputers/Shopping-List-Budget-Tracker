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

class ItemViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!;
    var list: List?;
    
    @IBOutlet weak var budgetLabel: UILabel!;
    @IBOutlet weak var totalLabel: UILabel!;
    @IBOutlet weak var progressView: UIProgressView!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.loadStats();
        self.updateProgressBar();
    }

    @IBAction func addName(sender: AnyObject) {
        self.showAddName();
    }
    
    func setList(list:List?) {
        self.list = list;
        self.title = list!.name;
    }
    
    // show add name alert box
    func showAddName() {
        var alert = UIAlertController(title: "Add a new item", message: "Name of item:", preferredStyle: UIAlertControllerStyle.Alert);
        
        // save button
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, {
            (action: UIAlertAction!) -> Void in
            // save button clicked so get name, show price alert box
            let textField = alert.textFields![0] as UITextField;
            self.showAddPrice(textField.text);
        });
        
        // cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, {
            (action: UIAlertAction!) -> Void in
        });
        
        // texbox configuration
        alert.addTextFieldWithConfigurationHandler({
            (textField: UITextField!) -> Void in
        });
        
        // add buttons to alert box
        alert.addAction(saveAction);
        alert.addAction(cancelAction);
        
        // show alert box
        presentViewController(alert, animated: true, completion: nil);
    }
    
    func showAddPrice(name:String) {
        var alert = UIAlertController(title: "Add price", message: "Price for " + name + ":", preferredStyle: .Alert);
        
        // save button
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, {
            (action: UIAlertAction!) -> Void in
            // save button clicked, save item
            let textField = alert.textFields![0] as UITextField;
            textField.keyboardType = UIKeyboardType.NumberPad;
            let price = NSString(string: textField.text);
            
            self.saveItem(name, price: price.doubleValue, checked: false);
            self.loadTable();
            self.loadStats();
        });
        
        // cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, {
            (action: UIAlertAction!) -> Void in
        });
        
        // textbox configuration
        alert.addTextFieldWithConfigurationHandler({
            (textField: UITextField!) -> Void in
            // they are entering a price so show the decimal keyboard
            textField.keyboardType = UIKeyboardType.DecimalPad;
        });
        
        // add buttons to alert box
        alert.addAction(saveAction);
        alert.addAction(cancelAction);
        
        // show alert box
        presentViewController(alert, animated: true, completion: nil);
    }
    
    func saveItem(name: String, price: Double, checked: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
        let managedContext = appDelegate.managedObjectContext!;
        let entity =  NSEntityDescription.entityForName("Item", inManagedObjectContext: managedContext);
        
        // create a new item object
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as Item;
        item.name = name;
        item.price = price;
        item.list = list!;
        
        var error: NSError?;
        if (!managedContext.save(&error)) {
            println("Could not save \(error), \(error?.userInfo)");
        }
    }
    
    func updateItem() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
        let managedContext = appDelegate.managedObjectContext!;
        
        var error: NSError?;
        if (!managedContext.save(&error)) {
            println("Could not save \(error), \(error?.userInfo)");
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list!.item.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "ItemViewCell";
        let items = self.list!.item.allObjects as NSArray;
        let item = items.objectAtIndex(indexPath.row) as Item;
        
        var cell: ItemViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier) as? ItemViewCell;
        
        if (cell? == nil) {
            cell = ItemViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier:identifier);
        }
        
        let price: Double? = item.valueForKey("price") as Double?;
        
        cell!.name.text = item.valueForKey("name") as String?;
        cell!.price.text = String(format:"%.2f", price!);
        
        return cell!;
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // delete item
        var error: NSErrorPointer = NSErrorPointer();
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
        let managedContext = appDelegate.managedObjectContext!;
        
        let items = self.list!.item.allObjects as NSArray;
        let item = items.objectAtIndex(indexPath.row) as Item;
        
        managedContext.deleteObject(item);
        managedContext.save(error);
        
        self.loadTable();
        self.loadStats();
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // if the user selects an item we will let them edit the price
        let items = self.list!.item.allObjects as NSArray;
        let item = items.objectAtIndex(indexPath.row) as Item;
        
        var alert = UIAlertController(title: "Add price", message: "Price for " + item.name + ":", preferredStyle: UIAlertControllerStyle.Alert);
        
        // save button
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, {
            (action: UIAlertAction!) -> Void in
            // user clicked save button so save new price
            let textField = alert.textFields![0] as UITextField;
            textField.keyboardType = UIKeyboardType.NumberPad;
            let price = NSString(string: textField.text);
            
            // update item object with new price
            item.price = price.doubleValue;
            
            // save item, update stats and reload table
            self.updateItem();
            self.loadTable();
            self.loadStats();
        });
        
        // cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, {
            (action: UIAlertAction!) -> Void in
        });
        
        // textbox configuration
        alert.addTextFieldWithConfigurationHandler({
            (textField: UITextField!) -> Void in
            // they are entering a price so show the decimal keyboard
            textField.keyboardType = UIKeyboardType.DecimalPad;
        });
        
        // add buttons to alert box
        alert.addAction(saveAction);
        alert.addAction(cancelAction);
        
        // show alert box
        presentViewController(alert, animated: true, completion: nil);
    }
    
    func updateProgressBar() {
        self.progressView.progress = (self.getTotal() / self.list!.budget.floatValue);
    }
    
    func getTotal() -> Float {
        let items = self.list!.item.allObjects as NSArray;
        var total: Float = 0;
        for item: Item in items as [Item] {
            total += item.price.floatValue;
        }
        
        return total;
    }
    
    func loadStats() {
        self.updateProgressBar();
        
        let budget = String(format:"%.2f", self.list!.budget.floatValue);
        self.budgetLabel.text = budget;
        
        self.totalLabel.text = String(format:"%.2f", self.getTotal());
    }
    
    func loadTable() {
        self.tableView.reloadData();
    }
    
    @IBAction func backToListsClick(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier("ListsNavViewController") as UIViewController;
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
}

