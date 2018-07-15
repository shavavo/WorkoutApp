//
//  ViewController.swift
//  WOapp
//
//  Created by David Cheng on 11/23/17.
//  Copyright © 2017 David Cheng. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // For development: deletes all Workouts in context
    @IBAction func clear(_ sender: Any) {
        deleteAllRecords()
        load()
        tableView.reloadData()
    }
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var newWorkoutTitle: UILabel!
    @IBOutlet weak var expand: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var repIntSegment: UISegmentedControl!
    @IBOutlet weak var picker1: UIPickerView!
    @IBOutlet weak var ofLabel: UIView!
    @IBOutlet weak var picker2: UIPickerView!
    @IBOutlet weak var finalNameLabel: UILabel!
    @IBOutlet weak var finalName: UILabel!
    @IBOutlet weak var editFinalName: UIButton!
    @IBOutlet weak var doneExercise: UIButton!
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var exerciseNameField: UITextField!
    @IBOutlet weak var exerciseTableView: UITableView!
    @IBOutlet weak var addNewExerciseButton: UIButton!
    @IBOutlet weak var doneWorkoutButton: UIButton!
    @IBOutlet weak var editOrderButton: UIButton!
    
    
    var context:NSManagedObjectContext!
    var workouts = [Workout]()
    var activeWorkout:Workout!
    var editingAt = -1
    var workoutAt = -1
    var segmentSelection = 0
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var hasLoaded:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(gestureRecognizer:)))
        self.exerciseTableView.addGestureRecognizer(longpress)
        
        
        // Intialize context for Core Data
        context = DatabaseControl.getContext()
        
        // Load workouts from context
        load()
        
        // Use to delete all Workouts
        //deleteAllRecords()
        
        // Used to track presses when keyboard is present
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        // Set tags for shared delegate/data sources
        nameField.tag = 0
        nameField.delegate = self
        
        exerciseNameField.tag = 1
        exerciseNameField.delegate = self
        
        tableView.tag = 0
        exerciseTableView.tag = 1
        
        addButton.tag = 0
        doneWorkoutButton.tag = 1
        
        // Initialize elements not needed
        animateOut(a: [titleLabel, newWorkoutTitle, nameField, nameLabel, firstLabel, repIntSegment, picker1, ofLabel, picker2, finalName, finalNameLabel, editFinalName, doneExercise, exerciseNameLabel, exerciseNameField, exerciseTableView, addNewExerciseButton, doneWorkoutButton])
        
        // Graphics intialization
        doneExercise.layer.cornerRadius = 10
        
        titleLabel.transform = CGAffineTransform(translationX: -titleLabel.frame.width/8, y: 0)
        titleLabel.alpha = 0.0
        
        addButton.layer.cornerRadius = 30
        doneWorkoutButton.layer.cornerRadius = 30
        expand.layer.cornerRadius = 20
        
        addNewExerciseButton.layer.cornerRadius = 10
        
        let path = UIBezierPath(roundedRect: picker1.bounds, byRoundingCorners: [.bottomLeft], cornerRadii: CGSize(width: 5, height: 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        picker1.layer.mask = maskLayer
        
        let path2 = UIBezierPath(roundedRect: picker2.bounds, byRoundingCorners: [.bottomRight], cornerRadii: CGSize(width: 5, height: 5))
        let maskLayer2 = CAShapeLayer()
        maskLayer2.path = path2.cgPath
        picker2.layer.mask = maskLayer2
        
        
        // Welcome Title
        animateIn(a: [titleLabel], delay: 0.0)
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //load()
        if delegate.hasLoaded == true {
            // Animate in table view cells
            let cells = tableView.visibleCells
            for cell in cells {
                cell.transform = CGAffineTransform(translationX: view.frame.width/8, y: 0)
                cell.alpha = 0.0
                
            }
            
            var delay = 0.1
            
            for cell in cells{
                UIView.animate(withDuration: 1.0, delay: delay, options: [], animations: {
                    cell.transform = .identity
                })
                
                UIView.animate(withDuration: 1.5, delay: delay + 0.3, options: [], animations: {
                    
                    cell.alpha = 1.0
                })
                
                delay += 0.05
                
            }
            delegate.hasLoaded = false
        }
            
       
        
      
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /* New workout button is pressed
        -Create new activeWorkout
        -Acts as cancel button if in edit mode */
    @IBAction func addButtonPressed(_ sender: Any) {

        nameField.text = ""
        exerciseNameField.text = ""
        
        picker1.selectRow(2, inComponent: 0, animated: false)
        picker2.selectRow(7, inComponent: 0, animated: false)
        
        // Create new Workout
        if addButton.transform == .identity {
            // Animate in expand, title, name field, and name field label
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
                self.addButton.transform = CGAffineTransform(rotationAngle: CGFloat(45*(Float.pi/180)))
                self.addButton.backgroundColor = #colorLiteral(red: 0.949, green: 0.1529, blue: 0.1412, alpha: 1) /* #f22724 */
                
            })
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                self.expand.transform = CGAffineTransform(scaleX: 50, y: 50)
            })
            
            animateIn(a: [newWorkoutTitle], delay: 0.0)
            animateIn(a: [nameLabel, nameField], delay: 0.2)
            self.nameField.becomeFirstResponder()
            
            activeWorkout = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: context) as! Workout
        }
        else{
            let alert = UIAlertController(title: "Back to Workouts", message: "Are you sure want to stop editing " + finalName.text! + "? New workouts will not be saved.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
            alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.destructive) { (action:UIAlertAction!) in
                self.animateOut(a: [self.newWorkoutTitle, self.nameField, self.nameLabel, self.firstLabel, self.repIntSegment, self.picker1, self.ofLabel, self.picker2, self.finalName, self.finalNameLabel, self.editFinalName, self.doneExercise, self.exerciseNameLabel, self.exerciseNameField, self.exerciseTableView, self.addNewExerciseButton, self.doneWorkoutButton])
                
                
                UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
                    self.addButton.transform = .identity
                    self.addButton.backgroundColor = #colorLiteral(red: 0.1255, green: 0.4235, blue: 0.8549, alpha: 1) /* #206cda */
                    
                })
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                    self.expand.transform = .identity
                })
                
                self.context.delete(self.activeWorkout)
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Edit final name of workout
    @IBAction func editFinalName(_ sender: Any) {
        animateOut(a: [finalName, finalNameLabel, editFinalName])
        animateIn(a: [nameLabel, nameField], delay: 0.0)
        self.nameField.becomeFirstResponder()
    }
    
    // Create new exercise
    @IBAction func addNewExercise(_ sender: Any) {
        animateOut(a: [exerciseTableView, addNewExerciseButton, doneWorkoutButton])
        exerciseNameField.text = "Exercise " + String((activeWorkout.exercise?.count)!+1)
        animateIn(a: [exerciseNameLabel, exerciseNameField, repIntSegment, picker1, ofLabel, picker2, doneExercise], delay: 0.0)
    }
    
    // Type of exercise is changed
    @IBAction func segmentChanged(_ sender: Any) {
        if segmentSelection == 0 {
            segmentSelection = 1
            picker2.selectRow(5, inComponent: 0, animated: true)
        }
        else if segmentSelection == 1 {
            segmentSelection = 0
            picker2.selectRow(7, inComponent: 0, animated: true)
        }
        
        picker2.reloadComponent(0)
    }
    
    // Done editing new exercise
    @IBAction func doneNewExercise(_ sender: Any) {
        animateOut(a: [firstLabel, exerciseNameLabel, exerciseNameField, repIntSegment, picker1, ofLabel, picker2, doneExercise])
        animateIn(a: [exerciseTableView, addNewExerciseButton, doneWorkoutButton], delay: 0.0)
        
        let activeExercise:Exercise = NSEntityDescription.insertNewObject(forEntityName: "Exercise", into: context) as! Exercise
        
        activeExercise.name  = exerciseNameField.text!
        activeExercise.sets = Int16(picker1.selectedRow(inComponent: 0) + 1)
        
        if segmentSelection == 0 {
            activeExercise.type = "Repetition"
            activeExercise.reps = Int16(picker2.selectedRow(inComponent: 0) + 1)
        } else {
            activeExercise.type = "Interval"
            activeExercise.reps = Int16((picker2.selectedRow(inComponent: 0) + 1) * 5)
        }
        
        if editingAt == -1 {
            activeWorkout.addToExercise(activeExercise)
        } else {
            editingAt = -1
        }
        
        exerciseTableView.reloadData()
        
        let cells = exerciseTableView.visibleCells
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: view.frame.width/16, y: 0)
            cell.alpha = 0.0
        }
        
        var delay = 0.2
        
        for cell in cells{
            UIView.animate(withDuration: 0.3, delay: delay, options: [], animations: {
                cell.transform = .identity
            })
            
            UIView.animate(withDuration: 0.4, delay: delay, options: [], animations: {
                
                cell.alpha = 1.0
            })
            
            delay += 0.05
            
        }
    }
    
    @IBAction func editOrder(_ sender: Any) {
        if exerciseTableView.isEditing == false {
            editOrderButton.setTitle("Done Editing", for: .normal)
            exerciseTableView.setEditing(true, animated: true)
        } else {
            editOrderButton.setTitle("Edit", for: .normal)
            exerciseTableView.setEditing(false, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        var rowToMove = activeWorkout.exercise![sourceIndexPath.row] as! Exercise
        activeWorkout.removeFromExercise(at: sourceIndexPath.row)
        activeWorkout.insertIntoExercise(rowToMove, at: destinationIndexPath.row)

    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if tableView.tag == 0{
                let alert = UIAlertController(title: "Delete", message: "Are you sure want to delete this workout?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
                alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.destructive) { (action:UIAlertAction!) in
                        self.context.delete(self.workouts[indexPath.row])
                        self.workouts.remove(at: indexPath.row)
                        self.save()
                        self.tableView.deleteRows(at: [indexPath], with: .left)
                    })
                self.present(alert, animated: true, completion: nil)
                
                
            }
            else if tableView.tag == 1{
                let temp = activeWorkout.exercise![indexPath.row] as! Exercise
                activeWorkout.removeFromExercise(temp)
                exerciseTableView.deleteRows(at: [indexPath], with: .left)
                // exerciseTableView.reloadData()
            }
            
        }
        
    }
    
    
    // Done editing workout
    @IBAction func doneEditingWorkout(_ sender: Any) {
        activeWorkout.name = finalName.text!
        activeWorkout.lastUsed = nil
        activeWorkout.parts = Int16(activeWorkout.exercise!.count)
        workouts.append(activeWorkout)
        tableView.reloadData()
        
        
        animateOut(a: [newWorkoutTitle , finalNameLabel, finalName, editFinalName, exerciseTableView, addNewExerciseButton, doneWorkoutButton])
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
            self.addButton.transform = .identity
            self.addButton.backgroundColor = #colorLiteral(red: 0.1255, green: 0.4235, blue: 0.8549, alpha: 1) /* #206cda */
            
        })
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
            self.expand.transform = .identity
        })
        
        save()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController2 = segue.destination as? ViewController2 {
            viewController2.workout = workouts[workoutAt]
            viewController2.exercises = workouts[workoutAt].exercise?.array as! [Exercise]
        }
    }

    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.tag == 0)  {
            if (nameField.text?.isEmpty)!{
                finalName.text = "My Workout"
            } else {
                finalName.text = nameField.text
            }
        
            animateOut(a: [nameField, nameLabel])
        
            animateIn(a: [finalNameLabel, finalName, editFinalName], delay: 0.0)
        
            if  (activeWorkout.exercise?.count==0){
                exerciseNameField.text = "Excercise " + String((activeWorkout.exercise?.count)! + 1)
                
                animateIn(a: [firstLabel], delay: 0.2)

                animateIn(a: [exerciseNameLabel, exerciseNameField], delay: 0.3)

                animateIn(a: [repIntSegment, picker1, ofLabel, picker2], delay: 0.4)

                animateIn(a: [doneExercise], delay: 0.5)
            }
            
        }else if(textField.tag == 1){
            if exerciseNameField.text == "" {
                exerciseNameField.text = "Excercise " + String((activeWorkout.exercise?.count)! + 1)
            }
        }
        self.view.endEditing(true)
        return true
    }
    
    // Tableview Data Source and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            return workouts.count
        } else if tableView.tag == 1 {
            if let temp = activeWorkout {
                return (temp.exercise?.count)!
            }
            else {
                return 0
            }
            
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "workout", for: indexPath) as! workoutCell
            
            cell.workoutName.text = workouts[indexPath.row].name
            if let date = workouts[indexPath.row].lastUsed{
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                cell.lastUsed.text = dateFormatter.string(from: date)
            } else{
                cell.lastUsed.text = "Never"
                
            }
            
            cell.steps.text = String(workouts[indexPath.row].parts)
            cell.view.layer.cornerRadius = 15
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "exercise", for: indexPath) as! exerciseCell
            
            let exercises = activeWorkout.exercise?.array as! [Exercise]
            cell.exerciseName.text = exercises[indexPath.row].name
            cell.sets.text = String(exercises[indexPath.row].sets)
            if exercises[indexPath.row].type == "Repetition" {
                cell.amount.text = String(exercises[indexPath.row].reps)
            } else {
                cell.amount.text = String(exercises[indexPath.row].reps) + " seconds"
            }

            cell.view.layer.cornerRadius = 15

            return cell
        }
    }
    
    // Tableview delegate and datasource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            animateOut(a: [tableView])
            
            workoutAt = indexPath.row
            
            performSegue(withIdentifier: "startWorkout", sender: nil)
            
        } else if tableView.tag == 1 {
            animateOut(a: [doneWorkoutButton, exerciseTableView, addNewExerciseButton])
            animateIn(a: [exerciseNameLabel, exerciseNameField, repIntSegment, picker1, picker2, ofLabel, doneExercise], delay: 0.0)
            editingAt = indexPath.row
            let exercises = activeWorkout.exercise?.array as! [Exercise]
            exerciseNameField.text = exercises[editingAt].name
            if exercises[editingAt].type == "Repetition" {

                picker2.selectRow(Int(exercises[editingAt].reps) - 1, inComponent: 0, animated: false)
            } else {
                segmentSelection = 0
                segmentChanged(repIntSegment)
                picker2.selectRow(Int(exercises[editingAt].reps/5) - 1, inComponent: 0, animated: false)
            }
            picker1.selectRow(Int(exercises[editingAt].sets) - 1, inComponent: 0, animated: false)
            
            
            
        }
    }
    
    
    
    
    // Pickerview Data Source and Delegate
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return 30
        }
        else if pickerView.tag == 1{
            return 50
        }
        
        return 1;
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        var titleData:String = ""
        
        if pickerView.tag == 0{
            titleData = "\(row+1)"
            label.textAlignment = .right
        }
        else if pickerView.tag == 1{
        
            if segmentSelection == 1{
                titleData = "\((row+1)*5)"
            }
            else if segmentSelection == 0{
                titleData = "\((row+1))"
            }
            label.textAlignment = .left
        }
        
        let myTitle = NSAttributedString(string: titleData)
        label.attributedText = myTitle
        return label
    }
    
    
    
    
    func animateIn(a: [UIView], delay: Double) {
        for a in a {
            UIView.animate(withDuration: 0.5, delay: delay, options: [], animations: {
                a.transform = .identity
            })
            
            UIView.animate(withDuration: 0.6, delay: delay, options: [], animations: {
                a.alpha = 1.0
            })
        }
    }
    
    func animateOut(a: [UIView]) {
        for a in a {
            a.alpha = 0.0
            a.transform = CGAffineTransform(translationX: -10, y: 0)
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        nameField.resignFirstResponder()
        let temp = UITextField()
        temp.tag = 0
        textFieldShouldReturn(temp)
        
        if exerciseNameField.text == "" {
            exerciseNameField.text = "Excercise " + String((activeWorkout.exercise?.count)! + 1)
        }
    }
    
    @objc func keyboardWillAppear() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func keyboardWillDisappear() {
        self.view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
    }
    
    func save() {
        DatabaseControl.saveContext()
    }
    
    func load() {
        let fetchRequest:NSFetchRequest<Workout> = Workout.fetchRequest()
        do{
            let searchResults = try context.fetch(fetchRequest)
            workouts = searchResults
        }
        catch{
            print("Error: \(error)")
        }
    }
    
    func deleteAllRecords() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longpress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longpress.state
        let locationInView = longpress.location(in: self.exerciseTableView)
        var indexPath = self.exerciseTableView.indexPathForRow(at: locationInView)
        
        switch state {
        case .began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = self.exerciseTableView.cellForRow(at: indexPath!) as! exerciseCell
                My.cellSnapShot = snapshopOfCell(inputView: cell)
                var center = cell.center
                My.cellSnapShot?.center = center
                My.cellSnapShot?.alpha = 0.0
                self.exerciseTableView.addSubview(My.cellSnapShot!)
                
                UIView.animate(withDuration: 0.25, animations: {
                    center.y = locationInView.y
                    My.cellSnapShot?.center = center
                    My.cellSnapShot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapShot?.alpha = 0.98
                    cell.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        cell.isHidden = true
                    }
                })
            }
            
        case .changed:
            var center = My.cellSnapShot?.center
            center?.y = locationInView.y
            My.cellSnapShot?.center = center!
            if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                
                var rowToMove = activeWorkout.exercise![(Path.initialIndexPath?.row)!] as! Exercise
                activeWorkout.removeFromExercise(at: (Path.initialIndexPath?.row)!)
                activeWorkout.insertIntoExercise(rowToMove, at: (indexPath?.row)!)
            
                
                self.exerciseTableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                Path.initialIndexPath = indexPath
            }
            
        default:
            let cell = self.exerciseTableView.cellForRow(at: Path.initialIndexPath!) as! exerciseCell
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: {
                My.cellSnapShot?.center = cell.center
                My.cellSnapShot?.transform = .identity
                My.cellSnapShot?.alpha = 0.0
                cell.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    My.cellSnapShot?.removeFromSuperview()
                    My.cellSnapShot = nil
                }
            })
        }
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    struct My {
        static var cellSnapShot: UIView? = nil
    }
    
    struct Path {
        static var initialIndexPath: IndexPath? = nil
    }


}

