//
//  GoalTableViewController.swift
//  SBM1
//
//  Created by Tatsuya Moriguchi on 6/5/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import UIKit
import CoreData

class GoalTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var selectedGoal: Goal?
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureFetchedResultsController()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureFetchedResultsController()
    }
    

 
    // MARK: -Configure FetchResultsController
        private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
        
        private func configureFetchedResultsController() {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
            
            // Declare sort descriptor
            let sortByDone = NSSortDescriptor(key: #keyPath(Goal.goalDone), ascending: true)
            let sortByTitle = NSSortDescriptor(key: #keyPath(Goal.goalTitle), ascending: true)
            
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

        
          private func deleteAction(goal: Goal, indexPath: IndexPath) {
               // Pop up an alert to warn a user of deletion of data
               let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this?", preferredStyle: .alert)
               let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
                   
                   // Declare ManagedObjectContext
                   let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                   
                   // Delete a row from tableview
                   let goalToDelete = self.fetchedResultsController?.object(at: indexPath)
                   // Delete it from Core Data
                   context.delete(goalToDelete as! NSManagedObject)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath)
            
            if let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal {
                      
                cell.textLabel?.text = goal.goalTitle
                if goal.goalDone == true { cell.accessoryType = .checkmark } else { cell.accessoryType = .none }
                
            }

            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal else { return }
   
            
            // Jump to MainTableViewController
            selectedGoal = goal
            self.performSegue(withIdentifier: "taskListSegue", sender: self)
            

        }

        
        // Override to support conditional editing of the table view.
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the specified item to be editable.
            return true
        }

        // Override to support editing the table view.

        override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?  {

            guard let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal else { return nil }
            let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in

                // Call delete action
                self.deleteAction(goal: goal, indexPath: indexPath)

              }
              return [deleteAction]
    }
    
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//                  guard let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal else { return nil }
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, boolValue) in
//            // Call delete action
//            self.deleteAction(goal: goal, indexPath: indexPath)
//
//            //UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
//
//              // Call delete action
//              self.deleteAction(goal: goal, indexPath: indexPath)
//
//            }
//
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }

    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskListSegue" {
            let destVC = segue.destination as! MainTableViewController
            destVC.selectedGoal = selectedGoal
            print("")
            print("selectedGoal for taskListSegue")
            print(selectedGoal)
            print("")
        }

    }

}
