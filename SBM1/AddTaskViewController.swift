//
//  AddTaskViewController.swift
//  SBM1
//
//  Created by Tatsuya Moriguchi on 6/4/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {

    var selectedGoal: Goal?
    
    @IBOutlet weak var taskTextField: UITextField!
    
    @IBOutlet weak var doneSwitch: UISwitch!
    
    
    @IBAction func saveOnPressed(_ sender: UIBarButtonItem) {
        
        
        if taskTextField.text != "" {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let task = Task(context: context)
            task.title = taskTextField.text
            task.goalAssigned = selectedGoal
            
            print("*******************************")
            print("Adding a task with selectedGoal: ")
            print(selectedGoal)
            print("*******************************")
            
            switch doneSwitch.isOn {
            case true:
                task.done = true
            case false:
                task.done = false
            }
            
            do {
                try context.save()
            }catch{
                print("Saving Error: \(error.localizedDescription)")
            }
            
            navigationController!.popViewController(animated: true)
            
        } else if taskTextField.text == "" {
            taskTextField.placeholder = "No Text Entry Found!! Type something here."
        } else {
            print("Unable to detect toDoTextField.text value.")
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
