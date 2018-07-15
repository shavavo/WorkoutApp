//
//  ViewController2.swift
//  WOapp
//
//  Created by David Cheng on 12/6/17.
//  Copyright © 2017 David Cheng. All rights reserved.
//

import UIKit

class ViewController2: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var workoutName: UILabel!
    @IBOutlet weak var workoutSets: UILabel!
    @IBOutlet weak var workoutReps: UILabel!
    @IBOutlet weak var workoutExerciseName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var workout:Workout!
    var exercises = [Exercise]()
    
    var activeExercise = 0;
    
    func save() {
        DatabaseControl.saveContext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workoutName.text = workout.name
        workoutSets.text = String(exercises[0].sets)
        workoutReps.text = String(exercises[0].reps)
        workoutExerciseName.text = exercises[0].name
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func animateOut(a: [UIView], scale: CGFloat) {
        for a in a {
            a.alpha = 0.0
            a.transform = CGAffineTransform(translationX: 0, y: scale*10)
        }
    }
    

    
    func loadNewExercise(){
        workoutSets.text = String(exercises[0].sets)
        workoutReps.text = String(exercises[0].reps)
        animateOut(a: [workoutExerciseName], scale: -1.0)
        workoutExerciseName.text = exercises[0].name
        animateIn(a: [workoutExerciseName], delay: 0)
    }
    
    @IBAction func minusSet(_ sender: Any) {
        if workoutSets.text != "1" {
            animateOut(a: [workoutSets], scale: 1.0)
            workoutSets.text = String(Int((workoutSets.text)!)! - 1)
            animateIn(a: [workoutSets], delay: 0.0)
        } else {
            if collectionView.numberOfItems(inSection: 0) == 1 {
                workout.lastUsed = Date()
                DatabaseControl.saveContext()
                performSegue(withIdentifier: "doneWorkout", sender: nil)
            } else {
                collectionView.deleteItems(at: [IndexPath(row: 0, section: 0)])
                collectionView.reloadData()
                loadNewExercise()
            }
            
        }
        
        
    }
    @IBAction func plusSet(_ sender: Any) {
        animateOut(a: [workoutSets], scale: -1.0)
        workoutSets.text = String(Int((workoutSets.text)!)! + 1)
        animateIn(a: [workoutSets], delay: 0.0)
    }
 
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exercise", for: indexPath) as! exerciseCollectionViewCell
        cell.border.layer.cornerRadius = 15
        cell.exerciseName.text = exercises[indexPath.row].name
        cell.sets.text = String(exercises[indexPath.row].sets)
        cell.reps.text = String(exercises[indexPath.row].reps)
        cell.type.text = exercises[indexPath.row].type
        if indexPath.row == activeExercise {
            cell.border.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1) /* #a8a8a8 */
        }
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
