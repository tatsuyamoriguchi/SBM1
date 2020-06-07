//
//  MigrateTableViewController.swift
//  SBM1
//
//  Created by Tatsuya Moriguchi on 6/6/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import UIKit
import CoreData

class MigrateTableViewController: UITableViewController, NSFetchedResultsControllerDelegate  {

    @IBAction func migrateOnPressed(_ sender: UIBarButtonItem) {
        // Use this to migrate all of the data in the tableview list.
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            if goal.goalDone == true { cell.backgroundColor = .gray } else { cell.backgroundColor = .clear }
           }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedGoal = self.fetchedResultsController?.object(at: indexPath) as? Goal else { return }
        
        migrateOneGoal(selectedGoal: selectedGoal)
        
        if let goalCell = tableView.cellForRow(at: indexPath) {
            goalCell.accessoryType = .checkmark
            selectedGoal.goalTitle = "*Delete if no need: " + selectedGoal.goalTitle!
            
        } else { print("Couldn't grab goalCell.")}
        
        
//        // Declare ManagedObjectContext
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        // Delete a row from tableview
//        let goalToDelete = self.fetchedResultsController?.object(at: indexPath)
//        // Delete it from Core Data
//        context.delete(goalToDelete as! NSManagedObject)
        
        
    }
    
    
    func migrateOneGoal(selectedGoal: Goal) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newGoal = Goal(context: context)
        
        newGoal.goalTitle = selectedGoal.goalTitle
        newGoal.goalDone = selectedGoal.goalDone
        
        migrateTasksOfOneGoal(selectedGoal: selectedGoal, newGoal: newGoal)
        
        do {
            try context.save()
        }catch{
            print("Saving or Deleting Goal context Error: \(error.localizedDescription)")
        }
    }
    
    func migrateTasksOfOneGoal(selectedGoal: Goal, newGoal: Goal) {

        let taskArray = selectedGoalTasksToArray(selectedGoal: selectedGoal)
        
        for taskToMigrate in taskArray {

            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newTask = Task(context: context)

            newTask.title = taskToMigrate.title
            newTask.done = taskToMigrate.done
            newTask.goalAssigned = newGoal //taskToMigrate.goalAssigned
            
            do {
                try context.save()
            }catch{
            }
        }
    }
    
    func selectedGoalTasksToArray(selectedGoal: Goal) -> Array<Task> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "goalAssigned == %@", selectedGoal)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var objects: [Task]
        do {
            try objects = context.fetch(fetchRequest) as! [Task]
            return objects
        } catch {
            print("Error in fetching Task data ")
            return []
        }
    }

}
