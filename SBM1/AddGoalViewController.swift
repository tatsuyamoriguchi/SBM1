//
//  AddGoalViewController.swift
//  SBM1
//
//  Created by Tatsuya Moriguchi on 6/5/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import UIKit

class AddGoalViewController: UIViewController {

    @IBOutlet weak var goalTitleTextField: UITextField!
    @IBOutlet weak var goalDoneSwitch: UISwitch!


    
    @IBAction func saveOnPressed(_ sender: UIBarButtonItem) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let goal = Goal(context: context)

        if goalTitleTextField.text != "" {
            goal.goalTitle = goalTitleTextField.text
            
            switch goalDoneSwitch.isOn {
            case true:
                goal.goalDone = true
            case false:
                goal.goalDone = false
            }
            
            do {
                try context.save()
            }catch{
                print("Saving Error: \(error.localizedDescription)")
            }
            
            navigationController!.popViewController(animated: true)
            
        } else if goalTitleTextField.text == "" {
            goalTitleTextField.placeholder = "No Text Entry Found!! Type something here."
        } else {
            print("Unable to detect toDoTextField.text value.")
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goalDoneSwitch.isOn = false
 

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
