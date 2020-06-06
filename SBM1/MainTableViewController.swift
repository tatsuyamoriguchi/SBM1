//
//  MainTableViewController.swift
//  SBM1
//
//  Created by Tatsuya Moriguchi on 6/4/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var selectedGoal: Goal?

    @IBAction func addOnPressed(_ sender: UIBarButtonItem) {

        self.performSegue(withIdentifier: "addTaskSegue", sender: self)
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        configureFetchedResultsController()
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        configureFetchedResultsController()
//    }

    
    
    // MARK: -Configure FetchResultsController
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    private func configureFetchedResultsController() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        print("********fetchRequest Task for selectedGoal: ")
        print(selectedGoal)
        print("")
        
        
        // Filtering tasks for selectedGoal
        fetchRequest.predicate = NSPredicate(format: "goalAssigned == %@", selectedGoal!)
          
        // Declare sort descriptor
        let sortByDone = NSSortDescriptor(key: #keyPath(Task.done), ascending: true)
        let sortByTitle = NSSortDescriptor(key: #keyPath(Task.title), ascending: true)
        
        // Sort fetchRequest array data
        fetchRequest.sortDescriptors = [sortByDone, sortByTitle]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
        print("controllerWillChangeContent was detected")
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            print("delete was detected.")
            self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            
            if(indexPath != nil) {
                self.tableView.cellForRow(at: indexPath! as IndexPath)
            }
        case .move:
            self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
            self.tableView.insertRows(at: [indexPath! as IndexPath], with: .fade)
        @unknown default:
            print("Fatal Error at switch")
        }
    }

    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        print("tableView data update was ended at controllerDidChangeContent().")
        tableView.reloadData()
    }

    
      private func deleteAction(task: Task, indexPath: IndexPath) {
           // Pop up an alert to warn a user of deletion of data
           let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this?", preferredStyle: .alert)
           let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
               
               // Declare ManagedObjectContext
               let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
               
               // Delete a row from tableview
               let taskToDelete = self.fetchedResultsController?.object(at: indexPath)
               // Delete it from Core Data
               context.delete(taskToDelete as! NSManagedObject)
            }
    
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           
           alert.addAction(deleteAction)
           alert.addAction(cancelAction)
           present(alert, animated: true)
           
       }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = fetchedResultsController {
             return frc.sections!.count
         }
         return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
        guard let sections = self.fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultscontroller")
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
            
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let task = self.fetchedResultsController?.object(at: indexPath) as? Task {
                  
            cell.textLabel?.text = task.title
            if task.done == true { cell.accessoryType = .checkmark } else { cell.accessoryType = .none }
            
            print("")
            print("Populating tableView with task.goalAssigned: ")
            print(task.goalAssigned)
            print("")
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let task = self.fetchedResultsController?.object(at: indexPath) as? Task else { return }
        
        // checkmark on select
        if let taskCell = tableView.cellForRow(at: indexPath) {
            
            if taskCell.accessoryType == .checkmark {
                taskCell.accessoryType = .none
                task.done = false
                //PlayAudio.sharedInstance.playClick(fileName: "whining", fileExt: ".wav")
            }else {
                
                taskCell.accessoryType = .checkmark
                task.done = true
                //PlayAudio.sharedInstance.playClick(fileName: "smallbark", fileExt: ".wav")
            }
        }
        
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?  {
        
        guard let task = self.fetchedResultsController?.object(at: indexPath) as? Task else { return nil }
          let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
              
              // Call delete action
              self.deleteAction(task: task, indexPath: indexPath)
              
          }

          return [deleteAction]
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "addTaskSegue" {
        let destVC = segue.destination as! AddTaskViewController
        destVC.selectedGoal = selectedGoal
        
        print("")
        print("selectedGoal for addTaskSegue")
        print(selectedGoal)
    }
    
    }
    
}
